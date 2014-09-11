class OGArray
	include Enumerable
	
	def initialize
		@array = []
	end
	
	def get_at index
		@array[index]
	end		
	
	def _array
		@array
	end
	
	def delete index
		if tr = Thread.current[:og_transaction]
			copy = tr.copy! self
			tr.before_set self, index, copy.get_at(index), nil
			return copy._array.delete index
		else
			raise "Changing OGObject is allowed only inside :transaction scope! (#{self}.#{index})"
		end
	end			
	
	def [] index
		if tr = Thread.current[:og_transaction]
			copy = tr.copy self
			if copy
				return copy.get_at index
			else
				return @array[index]
			end			
		else
			@array[index]
		end
	end
	
	def size
		if tr = Thread.current[:og_transaction]
			copy = tr.copy self
			if copy
				return copy._array.size
			else
				return @array.size
			end			
		else
			@array.size
		end
	end
	
	def []= index, value		
		if tr = Thread.current[:og_transaction]
			copy = tr.copy! self
			tr.before_set self, index, value, copy.get_at(index)
			return copy._array[index] = value
		else
			raise "Changing OGObject is allowed only inside :transaction scope! (#{self}.#{key})"
		end
	end 
	
	def << value		
		self[size] = value
	end
	
	def clear
		delete_if{true}
	end
	
	def delete_if &b	
		to_delete = []
		each_with_index do |value, index|
			to_delete << index if b.call value
		end
		to_delete.each{|index| delete index}
	end
			
	def each &b
		if tr = Thread.current[:og_transaction]
			copy = tr.copy self
			if copy
				copy._array.each &b
			else
				@array.each &b
			end			
		else
			@array.each &b
		end		
	end
	
	def each_with_index &b
		if tr = Thread.current[:og_transaction]
			copy = tr.copy self
			if copy
				copy._array.each_with_index &b
			else
				@array.each_with_index &b
			end			
		else
			@array.each_with_index &b
		end		
	end
	
	module ClassMethods
		def og_initialize_copy copy, original
			copy._array.replace original._array
		end
		
#		def og_each_reference array, b		
#			array._array.each{|value| b.call value if value.is_a? ValueObject}
#		end
#		
#		def og_each_reference_with_original copy, original, eb, vob					
#			copy._array.each_with_index do |value, index| 
#				old_value = original._array[index]
#				if value.is_a?(ValueObject) or old_value.is_a?(ValueObject) or value.is_a?(Entity) or old_value.is_a?(Entity)
#					b.call original, index, value, old_value 
#				end
#			end
#		end
		
		def og_write_back copy, original
			original._array.replace copy._array
		end
		
		def og_save copy, storage, transaction
			storage[:arrays].filter(:entity_id => copy.entity_id).delete
			copy._array.each_with_index do |v, index|		
				proc = Engine::Marshal::DUMP_TYPES[v.class]
				if proc
					data, klass = proc.call(v)					
				else 
					assert(v).is_a [ValueObject, Entity]
					data, klass = v.entity_id, Engine::Marshal::COMPLEX_OBJECT
				end								
				
				storage[:arrays].insert(:entity_id => copy.entity_id, 
																:index => index.to_s, 
																:value => data, :class => klass, 
																:extra => transaction.name)
			end								
		end
		
		def og_delete object, storage
			storage[:arrays].filter(:entity_id => object.entity_id).delete
		end
		
		def og_load array, entity_id, storage, o_resolver
			rows = storage[:arrays].filter :entity_id => entity_id
			rows.each do |row|								
				proc = Engine::Marshal::LOAD_TYPES[row[:class]]
				if proc
					value = proc.call row[:value]
				else 
					assert(row[:class]) == Engine::Marshal::COMPLEX_OBJECT
					value = o_resolver.call row[:value], array
				end
				
				index = row[:index].to_i
				
				array._array[index] = value
			end												
		end
		
		def og_initialize_storage db
			db.create_table :arrays do
				column :entity_id, :text
				column :index, :text
				column :value, :text
				column :class, :text
				column :extra, :text
				primary_key :entity_id, :index
			end
		end
	end
	extend ClassMethods
	
	OG_TYPES << self
end