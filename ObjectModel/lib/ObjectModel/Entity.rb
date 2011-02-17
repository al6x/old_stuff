module Entity	
	include OpenConstructor
	attr_reader :om_version, :entity_id, :om_repository, :back_references
	
	def == other
		@entity_id.should_not! :be_nil
		return false unless other.respond_to? :entity_id
		@entity_id == other.entity_id
	end
	
	def eql? other
		@entity_id.should_not! :be_nil
		return false unless self.class == other.class
		@entity_id == other.entity_id
	end
	
	def hash
		@entity_id.should_not! :be_nil
		return @entity_id.hash
	end		
	
	def to_s; 
		"#<#{self.class.name.split("::").last}: #{name}>" 
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
		
		tr.event_processor.fire_before self, :delete
		tr.event_processor.fire_after self, :delete
		
		copy.deleted!
	end
	
	def name
		if tr = Thread.current[:om_transaction]			
			if tr.changed? @entity_id
				tr.copies[@entity_id].name
			else
				@name
			end
		else
			@name
		end		
	end
	
	def name_get
		@name
	end
	
	def name= eid
		if tr = Thread.current[:om_transaction]			
			copy = tr.copy_get! self
			old_value = copy.name
			tr.event_processor.fire_before self, :name_update, eid, old_value			
			copy.name = eid
			tr.event_processor.fire_after self, :name_update, eid, old_value			
		else
			raise NoTransactionError
		end
	end		
	
	def path
		path, current = Path.new(name), self
		while current = current.parent
			path = Path.new(current.name) + path
		end 		
		path
	end
	
	def parent
		tr = Thread.current[:om_transaction]
		if tr and tr.changed? @entity_id
			entity_id = tr.copies[@entity_id].parent
			entity_id ? tr.resolve(entity_id) : nil
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
			copy.parent = parent != nil ? parent.entity_id : nil
		else
			raise NoTransactionError
		end
	end		
	
	def up method_name, *p, &b			
		result = nil
		e = search_up do |e| 
			result = e.respond_to method_name, *p
			result != nil
		end
		return result
		
		#		if respond_to? method_name
		#			value = send(method_name, *p, &b) 
		#			if value != nil
		#				return value
		#			elsif parent_get and parent_get.respond_to? method_name
		#				parent_get.up method_name, *p, &b
		#			else
		#				return value
		#			end
		#		else
		#			return parent_get.up method_name, *p, &b if parent_get
		#			return nil #raise NoMethodError, "Undefined method '#{method_name}' for '#{self.class.name}' and for it's parents!", caller
		#		end		
	end		
	
	def search_up &b
		return self if b.call self
		parent = parent_get
		if parent 
			if b.call(parent)
				return parent
			else
				return parent.search_up &b
			end
		else
			nil
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
		
		absolute_path = "#{path_get}/#{path}"		
		entity_id = @om_repository.index(:path).get_entity_id absolute_path
		
		entity_id.should! :be_a, [String, NilClass]		
		return entity_id != nil
	end
	
	def [] path		
		path = path.to_s if path.is_a? Path
		path.should! :be_a, String
		
		absolute_path = "#{path_get}/#{path}"		
		entity_id = @om_repository.index(:path).get_entity_id absolute_path
		raise_without_self NotFoundError, "Entity with Path '#{path}' not found!", ObjectModel if entity_id == nil
		
		entity_id.should! :be_a, String
		return @om_repository.by_id entity_id
	end
	
	def validate
		AnEntity::EntityType.validate_entity self
	end
	
	protected		
	def path_get
		path, current = Path.new(name_get), self
		while current = current.parent_get
			path = Path.new(current.name_get) + path
		end 
		path
	end
	
	def _single_child_get ivname
		tr = Thread.current[:om_transaction]			
		if tr and tr.changed? @entity_id
			entity_id = tr.copies[@entity_id][ivname]
			entity_id ? tr.resolve(entity_id) : nil
		else
			entity_id = instance_variable_get ivname
			entity_id ? @om_repository.by_id(entity_id) : nil
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
			copy[ivname] = value != nil ? value.entity_id : nil
			tr.event_processor.fire_after self, :new_child, name, value if value != nil						
		else
			raise NoTransactionError
		end
	end		
	
	def _single_reference_get ivname
		tr = Thread.current[:om_transaction]
		if tr and tr.changed? @entity_id
			entity_id = tr.copies[@entity_id][ivname]
			entity_id ? tr.resolve(entity_id) : nil
		else
			entity_id = instance_variable_get ivname
			entity_id ? @om_repository.by_id(entity_id) : nil
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
			copy[ivname] = value != nil ? value.entity_id : nil
			tr.event_processor.fire_after self, :new_reference, name, value if value != nil						
		else
			raise NoTransactionError
		end
	end		
	
	def _single_attribute_get ivname
		if tr = Thread.current[:om_transaction]			
			if tr.changed? @entity_id
				tr.copies[@entity_id][ivname]
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