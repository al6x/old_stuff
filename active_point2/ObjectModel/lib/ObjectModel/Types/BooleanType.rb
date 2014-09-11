class BooleanType
	class << self
		inherit Log
		
		def initial_value m, e
			false
#			e.instance_variable_set m.ivname, false
		end		
		
		def initialize_copy m, e, c
			value_copy = e.instance_variable_get(m.ivname).copy
			c[m.ivname] = value_copy
		end
		
		def load m, e, storage	
			row = storage[:entities_content][:entity_id => e.entity_id, :name => m.name.to_s]			
			raise LoadError unless row and row[:class] == "BOOLEAN"			
			
			e.instance_variable_set m.ivname, (row[:value] == "false" ? false : true)
		end
		
		def persist c, entity_id, m, storage					
			value = c[m.ivname] ? "true" : "false"
			storage[:entities_content].insert(
														:entity_id => entity_id, 
														:name => m.name.to_s,
														:value => value,
														:class => "BOOLEAN"
			)			
		end
		
		def write_back c, e, m
			value = c[m.ivname]
			value.should! :be_a, [TrueClass, FalseClass]
			e.instance_variable_set m.ivname, value
		end
		
		def validate_type value
			value == true or value == false
		end
	end
end