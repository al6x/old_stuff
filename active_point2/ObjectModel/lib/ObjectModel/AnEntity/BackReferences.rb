class BackReferences	
	def initialize entity_id
		@entity_id, @array = entity_id, []
	end
	
	def each &b
		tr = Thread.current[:om_transaction]
		if tr and tr.changed? @entity_id
			br = tr.copies[@entity_id].back_references			
			br._array.each{|entity_id| b.call tr.resolve(entity_id)}
		else
			self._array.each{|entity_id| b.call @om_repository.by_id(entity_id)}
		end		
	end
	
	def size
		if tr = Thread.current[:om_transaction]			
			if tr.changed? @entity_id
				tr.copies[@entity_id].back_references._array.size
			else
				@array.size
			end
		else
			@array.size
		end
	end
	
	def _array
		@array
	end
	
	class << self
		def initialize_storage db
			db.create_table :back_references do
				column :entity_id, :text
				column :referrer_id, :text
				
#				index :entity_id
			end
		end
		
		def print_storage db, name
			return unless name == nil or name == :back_references
			puts "\nBackReferences:"
			db[:back_references].print
		end
		
		def load e, storage
			rows = storage[:back_references].filter :entity_id => e.entity_id

			br = if rows.count > 0
				br = BackReferences.new e.entity_id
				rows.each do |row|
					br._array << EntityType.load_id(row[:referrer_id])
				end
				br
			else
				BackReferences.new e.entity_id
			end
#						p [e, br._array]
			e.instance_variable_set "@back_references", br
		end
		
		def write_back copy, entity
			entity.back_references._array.replace copy.back_references._array # TODO reimplement more efficiently
		end
		
		def initialize_copy e, c
			c.back_references = BackReferences.new e.entity_id
			c.back_references._array.replace e.back_references._array
		end
		
		def initialize_entity e
			e.instance_variable_set "@back_references", BackReferences.new(e.entity_id)
		end
		
		def persist c, entity_id, storage
			# TODO reimplement more efficiently			
			br = c.back_references
			storage[:back_references].filter(:entity_id => entity_id).delete
			if br._array.size > 0					
				br._array.each do |ref_id|		
					ref_id.should_not! :be_nil
					storage[:back_references].insert(
																					:entity_id => entity_id, 
																					:referrer_id => EntityType.dump_id(ref_id)
					)
				end								
			end									
		end
		
		def delete e, storage
			storage[:back_references].filter(:entity_id => e.entity_id).delete
		end
		
		def delete_backreference entity, reference, reference_copy
			br = reference_copy.back_references
			index = br._array.index entity.entity_id
			index.should! :>=, 0
			br._array.delete_at index
		end
		
		def new_backreference entity, reference, reference_copy
			br = reference_copy.back_references			
			br._array << entity.entity_id			
		end
		
		def delete_all_references_to e, c, &callback
			array = c.back_references._array.dup
			array.each{|entity_id| callback.call entity_id}						
		end
	end
end