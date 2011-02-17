class Repository			
	inherit Log
	attr_reader :storage, :indexes_storage, :stream_storage, :entity_listeners, :_index_manager
	
	INITIALIZATION_SYNC = Monitor.new
	
	def initialize name, params = {}
		INITIALIZATION_SYNC.synchronize do								
			super()
			
			config = Dir.getwd + "/config/object_model.yaml"
			
			@name = name.to_s; @name.should_not! :be_nil
			@params = params
			@dir = params[:directory] || CONFIG[:directory]
			@dir.should_not! :be_nil						
			
			check_the_same						
			
			# Disk Storages
			@storage = ObjectStorage.new @name, @dir
			@indexes_storage = Indexes::IndexStorage.new @name, @dir
			@stream_storage = StreamStorage.new @name, @dir, CONFIG[:buffer_size]																							
			
			# Synchronization
			@sync, @entity_loading_sync, @stream_sync = Sync.new, Monitor.new, Monitor.new												
			
			# Listeners
			@entity_listeners = []
			
			# Transaction Strategy
			if params.include? :transaction_strategy
				klass = params[:transaction_strategy].should! :be_a, Class
				@transaction_strategy = klass.new self
			else
				@transaction_strategy = Tools::DefaultTransactionStrategy.new self
			end												
			
			# Cache
			if params.include? :cache
				@entities_cache = params[:cache]
			else
				cache_class_name = CONFIG[:cache]; cache_class_name.should_not! :be_nil
				cache_class = eval cache_class_name, TOPLEVEL_BINDING, __FILE__, __LINE__
				cache_parameters = CONFIG[:cache_parameters]
				@entities_cache = cache_parameters ? cache_class.new(self, cache_parameters) : cache_class.new
			end			
			
			# Indexes
			index_def = params[:indexes] || []
			index_def.should! :be_a, Array
			index_def << Indexes::HashIndex.new(:path){|e| e.path}
			
			@index_manager = Indexes::Manager.new self			
			@indexes_storage.index_manager = @index_manager
			index_def.each{|index| @index_manager.add index}
			build_indexes			
		end
	end
	
	def isolate &b		
		@sync.synchronize :SH do 
			b.call
		end
	end
	
	def transaction transaction_or_name = nil, &b
		Thread.current[:om_transaction].should! :be_nil
		
		tr = if transaction_or_name.is_a? Transaction
			transaction_or_name
		else 			
			t = @transaction_strategy.create_new
			t.name = transaction_or_name if transaction_or_name
			t
		end
		tr.repository = self
		
		@sync.synchronize :SH do 
			begin
				Thread.current[:om_transaction] = tr
				b.call tr
			ensure
				Thread.current[:om_transaction] = nil
			end			
			if tr.commited?
				begin
					tr.event_processor.fire_after_commit
				ensure
					@transaction_strategy.after_commit tr if tr.managed
				end
			end
		end
		return tr
	end
	
	def commit tr
		if t = Thread.current[:om_transaction]
			t.should! :equal?, tr
			_commit tr
		else
			transaction(tr){_commit tr}
		end										
	end		
	
	def put key, value
		storage.put key, value
	end
	
	def get key
		storage.get key
	end
	
	def _commit tr
		processor = TransactionProcessor.new self, tr
		processor.check_outdated			
		tr.event_processor.fire_before_commit
		
		begin				
			@sync.synchronize(:EX) do 
				processor.write_back
				@storage.transaction do
					processor.persist					
					@index_manager.update tr			
				end
				@entities_cache.update tr
			end															
		rescue Exception => e
			close
			log.error "Fatal Error, Repository '#{@name}' can't be used!"
			raise e				
		end						
		
		tr.commited!
		return tr
	end
	
	def close		
		INITIALIZATION_SYNC.synchronize do
			@sync.synchronize(:EX) do
				@storage.close
				@indexes_storage.close
				@@runing.delete @name + @dir
			end
		end
	end		
	
	def clear
		close
		Repository.delete @name, @dir
		initialize @name, @params
	end
	
	def by_id entity_id		
		@entity_loading_sync.synchronize do
			entity = @entities_cache[entity_id]							
			unless entity
				entity = AnEntity::EntityType.load entity_id, self, @storage
				entity.should_not! :be_nil
				@entities_cache[entity_id] = entity
			end			
			return entity
		end
	end
	
	def include_id? entity_id
		@entity_loading_sync.synchronize do			
			entity = @entities_cache[entity_id]
			if entity
				return true
			else
				return AnEntity::EntityType.storage_include? entity_id, @storage
			end			
		end
	end
	
	def build_indexes
		@sync.synchronize(:EX){@index_manager.build_indexes}
	end
	
	def clear_indexes
		@sync.synchronize(:EX){@index_manager.clear_indexes}
	end
	
	def add_index index
		@sync.synchronize(:EX) do
			@index_manager.add index
			@index_manager.build_indexes
		end
	end
	
	def delete_index index_name
		@sync.synchronize(:EX){@index_manager.delete index_name}
	end
	
	def index name
		@index_manager[name]
	end
	
	def include? path
		path = path.to_s if path.is_a? Path
		path.should! :be_a, String
		
		entity_id = index(:path).get_entity_id path
		entity_id.should! :be_a, [String, NilClass]
		
		return entity_id != nil
	end
	
	def [] path		
		path = path.to_s if path.is_a? Path
		path.should! :be_a, String
		
		entity_id = index(:path).get_entity_id path
		raise_without_self NotFoundError, "Entity with Path '#{path}' not found!", ObjectModel if entity_id == nil
		
		entity_id.should! :be_a, String
		return by_id entity_id
	end		
	
	def to_s
		"#<Repository: #{@name}>" 
	end
	
	def inspect
		to_s
	end
	
	def print name = nil
		@storage.print name
	end
	
	class << self
		def delete name, directory = CONFIG[:directory]; 		
			INITIALIZATION_SYNC.synchronize do
				name = name.to_s
				path = File.join(directory, name)
				FileUtils.rm_rf path if File.exist? path
			end				
		end
	end
	
	def _index_manager; @index_manager end
	
	def print
		@storage.print
		@indexes_storage.print
	end
	
	protected	
	def check_the_same
		@@runing ||= Set.new
		if @@runing.include?(@name + @dir)
			raise_without_self "Forbiden to open two the same Repositories simultaneously!" 
		end
		@@runing << @name + @dir
	end							
end

# Stream
class Repository	
	def stream_metadata_read id
		@stream_storage.metadata_read id
	end
	
	def stream_metadata_put id, metadata
		@stream_storage.metadata_put id, metadata
	end
	
	def stream_size id
		@stream_storage.stream_size id
	end
	
	def size
		@storage.size		
	end
	
	def each &b
		AnEntity::EntityType.each_entity_in_repository self, &b
	end
	
	def stream_put data = nil, &block; 	
		id = nil
		@stream_sync.synchronize{id = StreamID.new(storage.generate(:stream_id))}		
		@stream_storage.stream_put id, data, &block		
		return id
	end
	
	def stream_put_each stream
		id = nil
		@stream_sync.synchronize{id = StreamID.new(storage.generate(:stream_id))}
		@stream_storage.stream_put_each id, stream
		return id
	end
	
	def stream_put_from_file file_name
		File.open file_name, "r" do |f|
			stream_put_each f
		end
	end
	
	def stream_read_to_file id, file_name
		File.open file_name, "w" do |to|
			stream_read_each(id){|part| to.write part}
		end
	end
	
	def stream_read id, &block; 
		@stream_storage.stream_read id, &block
	end
	
	def stream_read_each id, &block
		@stream_storage.stream_read_each id, &block
	end
	
	def stream_collect_garbage object_space = ObjectSpace 
		@stream_sync.synchronize do			
			ObjectSpace.garbage_collect
			memory = Set.new
			object_space.each_object(StreamID){|s| memory.add s.sid.to_s}			
			@stream_storage.list_of_ids.each do |id|
				@stream_storage.delete StreamID.new(id) unless memory.include?(id)
			end
		end
	end
end