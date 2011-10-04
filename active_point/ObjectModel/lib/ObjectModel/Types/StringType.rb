class StringType
	class << self
		def initial_value m, e
			""
#			e.instance_variable_set m.ivname, ""
		end			
		
		def initialize_copy m, e, c
			value_copy = e.instance_variable_get(m.ivname).dup
			c[m.ivname] = value_copy
		end
		
		def write_back c, e, m
			value = c[m.ivname]
			value.should! :be_a, String
			e.instance_variable_set m.ivname, value
		end
		
		def load m, e, storage	
			row = storage[:entities_content][:entity_id => e.entity_id, :name => m.name.to_s]
			
			raise LoadError unless row and row[:class] == "STRING"			
			e.instance_variable_set m.ivname, row[:value]
		end
		
		def persist c, entity_id, m, storage					
			storage[:entities_content].insert(
														:entity_id => entity_id, 
														:name => m.name.to_s,
														:value => c[m.ivname],
														:class => "STRING"
			)			
		end
		
		def validate_type value
			value.is_a? String
		end
	end
end