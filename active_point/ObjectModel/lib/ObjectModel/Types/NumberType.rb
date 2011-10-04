class NumberType
	class << self
		def initial_value m, e
			0
#			e.instance_variable_set m.ivname, 0
		end
		
		def initialize_copy m, e, c
			value_copy = e.instance_variable_get(m.ivname)
			c[m.ivname] = value_copy
		end
		
		def write_back c, e, m				
			value = c[m.ivname]
			value.should! :be_a, Numeric
			e.instance_variable_set m.ivname, value
		end
		
		def persist c, entity_id, m, storage					
			value, klass = dump_number c[m.ivname]
			storage[:entities_content].insert(
																				:entity_id => entity_id, 
																				:name => m.name.to_s,
																				:value =>value,
																				:class => klass
			)			
		end
		
		def load m, e, storage	
			row = storage[:entities_content][:entity_id => e.entity_id, :name => m.name.to_s]		
			raise LoadError unless row
			value = load_number row[:value], row[:class]
			
			e.instance_variable_set m.ivname, value
		end
		
		def validate_type value
			value.is_a? Numeric
		end
		
		protected
		def dump_number number
			case number
				when Fixnum then [number.to_s, "NUMBER_F"]
				when Bignum then [number.to_s, "NUMBER_B"]
				when Float then [number.to_s, "NUMBER_FL"]
			else
				should! :be_never_called
			end
		end
		
		def load_number value, klass
			case klass
				when "NUMBER_F" then value.to_i
				when "NUMBER_B" then value.to_i
				when "NUMBER_FL" then value.to_f
			else
				raise LoadError
			end
		end
	end
end