class DateType
	class << self
		def initial_value m, e
			nil
#			e.instance_variable_set m.ivname, nil
		end
		
		def initialize_copy m, e, c
			value = e.instance_variable_get(m.ivname)
			value_copy = value != nil ? value.clone : nil
			c[m.ivname] = value_copy
		end
		
		def write_back c, e, m				
			value = c[m.ivname]
			value.should! :be_a, [NilClass, DateTime]
			e.instance_variable_set m.ivname, value
		end				
		
		def persist c, entity_id, m, storage					
			value = c[m.ivname]			
			str_value = value == nil ? "nil" : value.to_s
			storage[:entities_content].insert(
																				:entity_id => entity_id, 
																				:name => m.name.to_s,
																				:value => str_value,
																				:class => "DATE"
			)			
		end
		
		def load m, e, storage	
			row = storage[:entities_content][:entity_id => e.entity_id, :name => m.name.to_s]						
			raise LoadError unless row and row[:class] == "DATE"			
			
			value = row[:value]
			e.instance_variable_set m.ivname, (value == "nil" ? nil : DateTime.parse(value))
		end
		
		def validate_type value
			value == nil or value.is_a? DateTime
		end
	end
end