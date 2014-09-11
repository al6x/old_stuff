class ObjectStorage	
	inherit Log
	TYPES_TO_INITIALIZE = []
	
	attr_reader :metadata
	
	def initialize name, dir
		folder = File.expand_path "#{dir}/#{name}" #.sub(/^\.\//, "")
		Dir.mkdir folder unless File.exist? folder		
		@db = Sequel.connect("sqlite://#{folder}/#{name}.db")
		@db.logger = log
		
		unless @db.table_exists? :metadata						
			initialize_db 
			TYPES_TO_INITIALIZE.each{|type| type.initialize_storage @db}
		end
		
		@metadata ||= @db[:metadata]		
		@custom_metadata ||= @db[:custom_metadata]
		@tables = {}		
	end
	
	def [] type
		@tables[type] ||= @db[type]
	end
	
	def generate generator_name
		generator_name = generator_name.to_s
		@db.transaction do 
			unless row = @metadata[:key => generator_name]
				@metadata << {:key => generator_name, :value => "0"}
				row = @metadata[:key => generator_name]
			end
			id = @metadata[:key => generator_name.to_s][:value].to_i
			@metadata.filter(:key => generator_name).update(:value => (id + 1).to_s)
			return id.to_s
		end
	end
	
	def size
		@db.transaction do 
			id = @metadata[:key => "size"][:value].to_i			
		end
	end
	
	def size= value
		@db.transaction do 
			value.should! :be_a, Number
			@metadata.filter(:key => "size").update(:value => value.to_s)
		end
	end
	
	def close
		@tables.clear
		@db.disconnect
	end
	
	def transaction &b
		@db.transaction &b
	end			
	
	def print name = nil
		TYPES_TO_INITIALIZE.each{|type| type.print_storage @db, name}
	end
	
	def get key
		key.should! :be_a, String
		row = @custom_metadata[:key => key]
		return row ? row[:value] : nil
	end
	
	def put key, value
		key.should! :be_a, String
		value.should! :be_a, String
		
		@custom_metadata.filter(:key => key).delete
		@custom_metadata << {:key => key, :value => value}
	end
	
	protected 
	def initialize_db
		@db.create_table :metadata do
			column :key, :text
			column :value, :text
			primary_key :key
		end				
		
		@db.create_table :custom_metadata do
			column :key, :text
			column :value, :text
			primary_key :key
		end				
		
		@metadata = @db[:metadata]
#		@metadata << {:key => "om_id", :value => "0"}
#		@metadata << {:key => "entity_id", :value => "0"}
#		@metadata << {:key => "stream_id", :value => "0"}
		@metadata << {:key => "size", :value => "0"}
	end
end