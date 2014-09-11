module Entity	
	include OpenConstructor
	attr_reader :om_version, :om_id, :om_repository, :back_references
	
	def == other
		@om_id.should_not! :be_nil
		return false unless other.respond_to? :om_id
		@om_id == other.om_id
	end
	
	def eql? other
		@om_id.should_not! :be_nil
		return false unless self.class == other.class
		@om_id == other.om_id
	end
	
	def hash
		@om_id.should_not! :be_nil
		return @om_id.hash
	end		
	
	def to_s; 
		"#<#{self.class.name.split("::").last}: #{entity_id}>" 
	end
	
	def inspect
		to_s
	end			
	
	def to_yaml io
		raise "You can't save Entity as YAML!"
	end
	
	def meta
		self.class.meta
	end
	
	def delete
		tr = Thread.current[:om_transaction]			
		raise NoTransactionError unless tr
		copy = tr.copy_get!(self)
		copy.new?.should! :be_false
		copy.deleted!
		tr.event_processor.fire_before self, :delete
		tr.event_processor.fire_after self, :delete
	end
	
	def entity_id
		if tr = Thread.current[:om_transaction]			
			if tr.changed? @om_id
				tr.copies[@om_id].entity_id
			else
				@entity_id
			end
		else
			@entity_id
		end		
	end
	
	def entity_id_get
		@entity_id
	end
	
	def entity_id= eid
		if tr = Thread.current[:om_transaction]			
			copy = tr.copy_get! self
			old_value = copy.entity_id
			tr.event_processor.fire_before self, :entity_id_update, eid, old_value			
			copy.entity_id = eid
			tr.event_processor.fire_after self, :entity_id_update, eid, old_value			
		else
			raise NoTransactionError
		end
	end		
	
	def entity_path
		path, current = Path.new(entity_id), self
		while current = current.parent
			path = Path.new(current.entity_id) + path
		end 
		path
	end
	
	def parent
		tr = Thread.current[:om_transaction]
		if tr and tr.changed? @om_id
				om_id = tr.copies[@om_id].parent
				om_id ? tr.resolve(om_id) : nil
		else
			@parent ? @om_repository.by_id(@parent) : nil
		end		
	end
	
	def parent_get
		@parent ? @om_repository.by_id(@parent) : nil
	end
	
	def _parent= parent		
		if tr = Thread.current[:om_transaction]			
			copy = tr.copy_get! self												
			copy.parent = parent != nil ? parent.om_id : nil
		else
			raise NoTransactionError
		end
	end		
	
	def up method_name, *p, &b					
		if respond_to? method_name
			value = send(method_name, *p, &b) 
			if value != nil
				return value
			elsif parent_get and parent_get.respond_to? method_name
				parent_get.up method_name, *p, &b
			else
				return value
			end
		else
			return parent_get.up method_name, *p, &b if parent_get
			return nil #raise NoMethodError, "Undefined method '#{method_name}' for '#{self.class.name}' and for it's parents!", caller
		end		
	end		
	
	def each specificator, &block
		case specificator
			when :attribute then AnEntity::EntityType.each_attribute self, &block
			when :child then AnEntity::EntityType.each_child self, &block
			when :reference then AnEntity::EntityType.each_reference self, &block
		else
			should! :be_never_called
		end
	end
	
	def include? path
		path = path.to_s if path.is_a? Path
		path.should! :be_a, String
		
		absolute_path = "#{entity_path_get}/#{path}"		
		om_id = @om_repository.index(:path).get_om_id absolute_path
		
		om_id.should! :be_a, [String, NilClass]		
		return om_id != nil
	end
	
	def [] path		
		path = path.to_s if path.is_a? Path
		path.should! :be_a, String
		
		absolute_path = "#{entity_path_get}/#{path}"		
		om_id = @om_repository.index(:path).get_om_id absolute_path
		raise_without_self NotFoundError, "Entity with Path '#{path}' not found!", ObjectModel if om_id == nil
		
		om_id.should! :be_a, String
		return @om_repository.by_id om_id
	end
	
	def validate
		AnEntity::EntityType.validate_entity self
	end
	
	protected		
	def entity_path_get
		path, current = Path.new(entity_id_get), self
		while current = current.parent_get
			path = Path.new(current.entity_id_get) + path
		end 
		path
	end
	
	def _single_child_get ivname
		tr = Thread.current[:om_transaction]			
		if tr and tr.changed? @om_id
				om_id = tr.copies[@om_id][ivname]
				om_id ? tr.resolve(om_id) : nil
		else
			om_id = instance_variable_get ivname
			om_id ? @om_repository.by_id(om_id) : nil
		end
	end
	
	def _single_child_set ivname, name, value		
		if tr = Thread.current[:om_transaction]			
			copy = tr.copy_get! self
			old_value = copy[ivname]
			
			if old_value != nil
				old_entity = tr.resolve(old_value)
				tr.event_processor.fire_before self, :delete_child, name, old_entity
				copy[ivname] = nil
				tr.event_processor.fire_after self, :delete_child, name, old_entity
			end
			
			tr.event_processor.fire_before self, :new_child, name, value if value != nil						
			copy[ivname] = value != nil ? value.om_id : nil
			tr.event_processor.fire_after self, :new_child, name, value if value != nil						
		else
			raise NoTransactionError
		end
	end		
	
	def _single_reference_get ivname
		tr = Thread.current[:om_transaction]
		if tr and tr.changed? @om_id
				om_id = tr.copies[@om_id][ivname]
				om_id ? tr.resolve(om_id) : nil
		else
			om_id = instance_variable_get ivname
			om_id ? @om_repository.by_id(om_id) : nil
		end
	end
	
	def _single_reference_set ivname, name, value	
		if tr = Thread.current[:om_transaction]			
			copy = tr.copy_get! self
			old_value = copy[ivname]
			
			if old_value != nil
				old_entity = tr.resolve(old_value)
				tr.event_processor.fire_before self, :delete_reference, name, old_entity
				copy[ivname] = nil
				tr.event_processor.fire_after self, :delete_reference, name, old_entity
			end
			
			tr.event_processor.fire_before self, :new_reference, name, value if value != nil						
			copy[ivname] = value != nil ? value.om_id : nil
			tr.event_processor.fire_after self, :new_reference, name, value if value != nil						
		else
			raise NoTransactionError
		end
	end		
	
	def _single_attribute_get ivname
		if tr = Thread.current[:om_transaction]			
			if tr.changed? @om_id
				tr.copies[@om_id][ivname]
			else
				instance_variable_get ivname
			end
		else
			instance_variable_get ivname
		end		
	end
	
	def _single_attribute_set ivname, name, value
		if tr = Thread.current[:om_transaction]			
			copy = tr.copy_get! self
			old_value = copy[ivname]
			tr.event_processor.fire_before self, :attribute_update, name, value, old_value			
			copy[ivname] = value
			tr.event_processor.fire_after self, :attribute_update, name, value, old_value			
		else
			raise NoTransactionError
		end
	end		
end
require "#{File.dirname(__FILE__)}/AnEntity/entity_cm"