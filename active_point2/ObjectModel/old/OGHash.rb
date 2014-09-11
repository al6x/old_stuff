class OGHash				
	def initialize
		@hash = {}
	end
	
	def get_by key
		@hash[key]
	end		
	
	def _hash
		@hash
	end
	
	def delete key
		if tr = Thread.current[:og_transaction]
			copy = tr.copy! self
			tr.before_set self, key, copy.get_by(key), nil, false
			return copy._hash.delete key
		else
			raise "Changing OGObject is allowed only inside :transaction scope! (#{self}.#{key})"
		end
	end			
	
	def [] key
		if tr = Thread.current[:og_transaction]
			copy = tr.copy self
			if copy
				return copy.get_by key
			else
				return @hash[key]
			end			
		else
			@hash[key]
		end
	end
	
	def size
		if tr = Thread.current[:og_transaction]
			copy = tr.copy self
			if copy
				return copy._hash.size
			else
				return @hash.size
			end			
		else
			@hash.size
		end
	end
	
	def []= key, value		
		if tr = Thread.current[:og_transaction]
			copy = tr.copy! self
			tr.before_set self, key, value, copy.get_by(key), false
			return copy._hash[key] = value
		else
			raise "Changing OGObject is allowed only inside :transaction scope! (#{self}.#{key})"
		end
	end 
	
	def clear
		delete_if{true}
	end
	
	def delete_if &b	
		to_delete = []
		each do |key, value|
			to_delete << key if b.call key, value
		end
		to_delete.each{|key| delete key}
	end
	
	def each &b
		if tr = Thread.current[:og_transaction]
			copy = tr.copy self
			if copy
				copy._hash.each &b
			else
				@hash.each &b
			end			
		else
			@hash.each &b
		end		
	end
	
	module ClassMethods
		def og_initialize_copy copy, original
			copy._hash.replace original._hash
		end
		
#		def og_each_reference hash, b
#			hash._hash.each{|key, value| b.call value if value.is_a? ValueObject}
#		end
#		
#		def og_each_reference_with_original copy, original, b					
#			copy._hash.each do |key, value| 
#				old_value = original._hash[key]
#				if value.is_a?(ValueObject) or old_value.is_a?(ValueObject)
#					b.call original, key, value, old_value 
#				end
#			end
#		end
		
		def og_write_back copy, original
			original._hash.replace copy._hash
		end
		
		def og_save copy, storage, transaction
			storage[:hashes].filter(:name => copy.name).delete
			copy._hash.each do |k, v|					
				proc = Engine::Marshal::DUMP_TYPES[v.class]
				if proc
					data, klass = proc.call(v)					
				else 
					assert(v).is_a [ValueObject, Entity]
					data, klass = v.name, Engine::Marshal::COMPLEX_OBJECT
				end
				
				proc = Engine::Marshal::DUMP_TYPES[k.class]
				if proc
					key_data, key_klass = proc.call(k)					
				else 
					assert(v).is_a [ValueObject, Entity]
					key_data, key_klass = v.name, Engine::Marshal::COMPLEX_OBJECT
				end
				
				storage[:hashes].insert(:name => copy.name, 
																:key_value => key_data, :key_class => key_klass, 
																:value => data, :class => klass, 
																:extra => transaction.name)
			end								
		end
		
		def og_delete object, storage
			storage[:hashes].filter(:name => object.name).delete
		end
		
		def og_load hash, name, storage, o_resolver
			rows = storage[:hashes].filter :name => name
			rows.each do |row|								
				proc = Engine::Marshal::LOAD_TYPES[row[:class]]
				if proc
					value = proc.call row[:value]
				else 
					assert(row[:class]) == Engine::Marshal::COMPLEX_OBJECT
					value = o_resolver.call row[:value], hash
				end
				
				proc = Engine::Marshal::LOAD_TYPES[row[:key_class]]
				if proc
					key_value = proc.call row[:key_value]
				else 
					assert(row[:key_class]) == Engine::Marshal::COMPLEX_OBJECT
					key_value = o_resolver.call row[:key_value], hash
				end
				
				hash._hash[key_value] = value
			end												
		end
		
		def og_initialize_storage db
			db.create_table :hashes do
				column :name, :text
				column :key_value, :text
				column :key_class, :text
				column :value, :text
				column :class, :text
				column :extra, :text
				primary_key :name, :key
			end
		end
	end
	extend ClassMethods
end