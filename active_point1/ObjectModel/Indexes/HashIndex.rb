class HashIndex
	attr_accessor :storage, :name, :repository
	
	def initialize name, &hasher
		name.should! :be_a, Symbol
		@name, @hasher = name, hasher
	end		
	
	def include? hash
		hash.should! :be_a, String
		
		return storage[@name][:hash => hash] != nil
	end
	
	def [] hash
		om_id = get_om_id hash		
		return om_id != nil ? @repository.by_id(om_id) : nil
	end
	
	def get_om_id hash
		row = storage[@name][:hash => hash.to_s]
		return row ? row[:om_id] : nil
	end
	
				
	def update entity, copy
		if copy.deleted?
			storage[@name].filter(:om_id => entity.om_id).delete	
		else 			
			hash = @hasher.call(entity)
			
			storage[@name].filter(:om_id => entity.om_id).delete	
			storage[@name].insert :hash => hash.to_s, :om_id => entity.om_id if hash != nil	
		end
	end
		
	def add entity
		hash = @hasher.call(entity)
		#		hash.should! :be_a, String
		storage[@name].insert :hash => hash.to_s, :om_id => entity.om_id if hash != nil
	end		
	
	def print_storage i_name
		return unless i_name == nil or i_name == @name
		puts "\nHashIndex #{@name}:"
		storage[@name].print
		@storage
	end
	
	def create_index
		if storage.db.table_exists? @name
			return true
		else			
			storage.db.create_table @name do			
				column :hash, :text
				column :om_id, :text
				primary_key :hash
			end
			return false
		end
	end
	
	def delete_index
		storage.db.drop_table @name if storage.db.table_exists? @name
	end		
end