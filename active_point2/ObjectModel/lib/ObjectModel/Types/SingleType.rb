class SingleType
	class << self
		inherit Log
		
		def initial_value m, e
			nil
#			e.instance_variable_set m.ivname, nil
		end				
		
		def initialize_copy m, e, c
			c[m.ivname] = e.instance_variable_get(m.ivname)
		end
		
		def write_back c, e, m										
			value = c[m.ivname]
			value.should! :be_a, [NilClass, String]
			e.instance_variable_set m.ivname, value
		end
		
		def load m, e, storage					
			row = storage[:entities_content][:entity_id => e.entity_id, :name => m.name.to_s]
			raise LoadError unless row
			
			value = AnEntity::EntityType.load_id! row[:value], row[:class]
			e.instance_variable_set m.ivname, value				
		end 			
		
		def persist c, entity_id, m, storage								
			value, klass = AnEntity::EntityType.dump_id! c[m.ivname]
			storage[:entities_content].insert(
																				:entity_id => entity_id, 
																				:name => m.name.to_s,
																				:value => value,
																				:class => klass
			)
		end
		
		def delete_all_children e, m						
			child = e.send m.name
			#			p [e.name, m.name, child]
			child.delete if child != nil
		end
		
		def delete_all_references_to referrer, e, m			
			referrer.send m.name.to_writer, nil if referrer.send(m.name) == e
		end
		
		def delete_from_parent e, parent, m
			if parent.send(m.name.to_reader) == e
				parent.send m.name.to_writer, nil
			end
		end
		
		def each e, m, &b
			v = e.send m.name
			b.call v if v != nil
		end
	end
end