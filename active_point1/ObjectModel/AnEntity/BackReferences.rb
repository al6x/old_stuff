class BackReferences	
	def initialize om_id
		@om_id, @array = om_id, []
	end
	
	def each &b
		tr = Thread.current[:om_transaction]
		if tr and tr.changed? @om_id
			br = tr.copies[@om_id].back_references			
			br._array.each{|om_id| b.call tr.resolve(om_id)}
		else
			self._array.each{|om_id| b.call @om_repository.by_id(om_id)}
		end		
	end
	
	def size
		if tr = Thread.current[:om_transaction]			
			if tr.changed? @om_id
				tr.copies[@om_id].back_references._array.size
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
				column :om_id, :text
				column :referrer_id, :text
			end
		end
		
		def print_storage db, name
			return unless name == nil or name == :back_references
			puts "\nBackReferences:"
			db[:back_references].print
		end
		
		def load e, storage
			rows = storage[:back_references].filter :om_id => e.om_id
			
			br = if rows.size > 0
				br = BackReferences.new e.om_id
				rows.each do |row|
					br._array << EntityType.load_id(row[:referrer_id])
				end
				br
			else
				BackReferences.new e.om_id
			end
#						p [e, br._array]
			e.instance_variable_set "@back_references", br
		end
		
		def write_back copy, entity
			entity.back_references._array.replace copy.back_references._array # TODO reimplement more efficiently
		end
		
		def initialize_copy e, c
			c.back_references = BackReferences.new e.om_id
			c.back_references._array.replace e.back_references._array
		end
		
		def initialize_entity e
			e.instance_variable_set "@back_references", BackReferences.new(e.om_id)
		end
		
		def persist c, om_id, storage
			# TODO reimplement more efficiently			
			br = c.back_references
			storage[:back_references].filter(:om_id => om_id).delete
			if br._array.size > 0					
				br._array.each do |ref_id|		
					ref_id.should_not! :be_nil
					storage[:back_references].insert(
																					:om_id => om_id, 
																					:referrer_id => EntityType.dump_id(ref_id)
					)
				end								
			end									
		end
		
		def delete e, storage
			storage[:back_references].filter(:om_id => e.om_id).delete
		end
		
		def delete_backreference entity, reference, reference_copy
			br = reference_copy.back_references
			index = br._array.index entity.om_id
			index.should! :>=, 0
			br._array.delete_at index
		end
		
		def new_backreference entity, reference, reference_copy
			br = reference_copy.back_references			
			br._array << entity.om_id			
		end
		
		def delete_all_references_to e, c, &callback
			array = c.back_references._array.dup
			array.each{|om_id| callback.call om_id}						
		end
	end
end