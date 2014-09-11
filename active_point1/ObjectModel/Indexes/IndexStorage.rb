class IndexStorage	
	inherit Log
	
	attr_reader :db
	attr_writer :index_manager
	
	def initialize name, dir
		folder = File.expand_path "#{dir}/#{name}"
		Dir.mkdir folder unless File.exist? folder		
		@db = Sequel.connect("sqlite://#{folder}/#{name}_indexes.db")
		@db.logger = log
		
		initialize_db unless @db.table_exists? :metadata						
		
		@metadata ||= @db[:metadata]		
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
		
	def close
		@tables.clear
		@db.disconnect
	end
	
	def transaction &b
		@db.transaction &b
	end	
	
	def print name = nil
		@index_manager.indexes.values.each{|index| index.print_storage name}
	end
	
	protected 
	def initialize_db
		@db.create_table :metadata do
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