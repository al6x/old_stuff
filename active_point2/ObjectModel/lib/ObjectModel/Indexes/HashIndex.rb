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
		entity_id = get_entity_id hash		
		return entity_id != nil ? @repository.by_id(entity_id) : nil
	end
	
	def get_entity_id hash
		row = storage[@name][:hash => hash.to_s]
		return row ? row[:entity_id] : nil
	end	
	
	def update entity, copy		
		storage[@name].filter(:entity_id => entity.entity_id).delete
		unless copy.deleted?
			hash = @hasher.call(entity)			
			storage[@name].insert :hash => hash.to_s, :entity_id => entity.entity_id if hash != nil	
		end
	end
	
	def add entity
		hash = @hasher.call(entity)
		#		hash.should! :be_a, String
		storage[@name].insert :hash => hash.to_s, :entity_id => entity.entity_id if hash != nil
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
				column :entity_id, :text
				primary_key :hash
				
#				index :hash
#				index :entity_id
			end
			return false
		end
	end
	
	def delete_index
		storage.db.drop_table @name if storage.db.table_exists? @name
	end		
end