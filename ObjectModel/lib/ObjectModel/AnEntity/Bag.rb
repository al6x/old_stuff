class Bag
	include Enumerable 
	
	def initialize entity, attr_name, repository		
		@entity, @entity_id, @attr_name, @repository = entity, entity.entity_id, attr_name, repository
		@array = []		
		@ivname = "@#{@attr_name}"
	end
	
	def _array
		@array
	end
	
	def delete value	
		if tr = Thread.current[:om_transaction]
			return unless value.is_a? Entity						
			copy = tr.copy_get! @entity
			previous = false
			copy[@ivname].delete_if do |entity_id| 
				if previous
					tr.event_processor.fire_after @entity, delete_item_method_name, @attr_name, value
					previous = false
				end
				
				if value.entity_id == entity_id
					tr.event_processor.fire_before @entity, delete_item_method_name, @attr_name, value
					previous = true
					true
				else
					false
				end
			end			
			
			tr.event_processor.fire_after @entity, delete_item_method_name, @attr_name, value if previous
		else
			raise NoTransactionError
		end
	end			
	
	def size
		if tr = Thread.current[:om_transaction]
			if tr.changed? @entity_id
				tr.copies[@entity_id][@ivname].size
			else
				@array.size
			end			
		else
			@array.size
		end
	end
	
	def << value		
		if tr = Thread.current[:om_transaction]
			tr.event_processor.fire_before @entity, new_item_method_name, @attr_name, value
			copy = tr.copy_get! @entity
			copy[@ivname].add value.entity_id
			tr.event_processor.fire_after @entity, new_item_method_name, @attr_name, value
		else
			raise NoTransactionError
		end
	end
	
	def clear
		delete_if{true}
	end
	
	def delete_if &b	
		if tr = Thread.current[:om_transaction]
			copy = tr.copy_get! @entity
			previous_entity = nil
			copy[@ivname].delete_if do |entity_id| 								
				entity = tr.resolve(entity_id)
				
				if previous_entity != nil
					tr.event_processor.fire_after @entity, delete_item_method_name, @attr_name, previous_entity
					previous_entity = entity
				end
				
				if b.call entity
					tr.event_processor.fire_before @entity, delete_item_method_name, @attr_name, entity
					previous = true
					true
				else
					false
				end
			end			
			
			if previous_entity != nil
				tr.event_processor.fire_after @entity, delete_item_method_name, @attr_name, previous_entity 
			end
		else
			raise NoTransactionError
		end		
	end
	
	def each &b
		tr = Thread.current[:om_transaction]
		if tr and tr.changed? @entity_id
				array = tr.copies[@entity_id][@ivname]			
				array.each{|entity_id| b.call tr.resolve(entity_id)}
		else
			@array.each{|entity_id| b.call @repository.by_id(entity_id)}
		end				
	end
	
	def ids
		if tr = Thread.current[:om_transaction]
			if tr.changed? @entity_id
				tr.copies[@entity_id][@ivname]
			else
				@array
			end				
		else
			@array
		end		
	end
	
	def to_s
		"#<Bag '#{@entity_id}': [#{@array.join(', ')}]>"
	end
	
	def empty?
		size == 0
	end
	
	def inspect
		to_s
	end
end