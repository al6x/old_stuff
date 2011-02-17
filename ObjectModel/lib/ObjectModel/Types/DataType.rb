class DataType
	class << self
		def initial_value m, e
			nil
#			e.instance_variable_set m.ivname, nil
		end
		
		def initialize_copy m, e, c			
			value = e.instance_variable_get(m.ivname)
			value_copy = value != nil ? Repository::StreamID.new(value.sid) : nil
			c[m.ivname] = value_copy
		end
		
		def write_back c, e, m				
			value = c[m.ivname]
			value.should! :be_a, [NilClass, Repository::StreamID]
			e.instance_variable_set m.ivname, value
		end
				
		def load m, e, storage	
			row = storage[:entities_content][:entity_id => e.entity_id, :name => m.name.to_s]			
			raise LoadError unless row and row[:class] == "STREAM_ID"			
			
			stream_id = row[:value]
			value = stream_id == "nil" ? nil : Repository::StreamID.new(stream_id)
			e.instance_variable_set m.ivname, value
		end
		
		def persist c, entity_id, m, storage					
			value = c[m.ivname]
			stream_id = value == nil ? "nil" : value.sid
			storage[:entities_content].insert(
														:entity_id => entity_id, 
														:name => m.name.to_s,
														:value => stream_id,
														:class => "STREAM_ID"
			)			
		end
		
		def validate_type value
			value == nil or value.is_a? StreamID
		end
	end
end