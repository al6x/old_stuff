module ObjectModel
	module Entity
		module ClassMethods			
			attr_accessor :self_meta
			
			def metadata &b
				Metadata::DSL.new self, &b
			end
			
			def _define_attribute m		
				n = m.name
				script = %{\
def #{n}
	_single_attribute_get "@#{n}"
end				

def #{n}= value
	_single_attribute_set "@#{n}", :#{n}, value
end

def #{n}_get
	@#{n}
end
}													
				class_eval script, __FILE__, __LINE__			
			end
			
			def _define_child m				
				n = m.name
				if m.type == Types::SingleType
					script = %{\
def #{n}
	_single_child_get "@#{n}"
end				

def #{n}= value
	_single_child_set "@#{n}", :#{n}, value
end

def #{n}_get
	return @#{n} ? @om_repository.by_id(@#{n}) : nil	
end
}								
					class_eval script, __FILE__, __LINE__			
				else
					class_eval{attr_reader n}
				end
			end
			
			def _define_reference m
				n = m.name
				if m.type == Types::SingleType
					script = %{\
def #{n}
	_single_reference_get "@#{n}"
end				

def #{n}= value
	_single_reference_set "@#{n}", :#{n}, value
end

def #{n}_get
	return @#{n} ? @om_repository.by_id(@#{n}) : nil
end
}								
					class_eval script, __FILE__, __LINE__				
				else
					class_eval{attr_reader n}
				end
			end
			
			def meta
				meta = ancestors.reverse.inject nil do |r, a| 
					if a.respond_to? :self_meta
						self_meta.should_not! :be_nil
						r ? a.self_meta.inherit(r) : a.self_meta
					else
						r
					end
				end			
				return meta
			end
			
			def new eid = nil, entity_id = nil, original_new = nil				
				e = super()
				if original_new == "original_new"
					return e 
				else
					original_new.should! :be_nil
				end
				
				tr = Thread.current[:om_transaction]			
				raise_without_self NoTransactionError, "", ObjectModel unless tr
				
				AnEntity::EntityType.initialize_new_entity e, eid, entity_id, tr								
				
				tr.new_entities[e.entity_id] = e 
				c = tr.copy_get! e
				c.new!
				
				tr.event_processor.fire_after e, :new
				
				return e
			end
		end
		extend ClassMethods
	end	
end