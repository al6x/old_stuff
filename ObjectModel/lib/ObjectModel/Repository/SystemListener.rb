class SystemListener
	def initialize transaction
		@transaction = transaction
		@deleted_parents = {}
	end
	
	def before_attribute_update entity, name, new, old
		name.should! :be_a, Symbol
		AnEntity::EntityType.validate_attribute entity, name, new, old
	end
	
	def before_name_update entity, new, old		
		return if new == old
		raise_without_self "name '#{new}' should be a String!", ObjectModel unless new.is_a? String
		raise_without_self "name '#{new}' shouldn't be Emtpy!", ObjectModel if new.empty?
		raise_without_self "name '#{new}' should not include '/' Symbol!", ObjectModel if new.include? '/'
		
		check_name_uniquity entity, new		
	end
	
	def after_new_parent entity, old_parent
		check_name_uniquity entity, entity.name
	end
	
	def after_delete_parent entity, old_parent
		check_name_uniquity entity, entity.name
	end
	
	def before_commit entities
		entities.should! :be_a, Array
		entities.each do |e|
			AnEntity::EntityType.validate_entity e
		end
	end
	
	def after_new entity
		AnEntity::EntityType.custom_initialization entity
	end
	
	def before_new_child entity, name, child				
		raise_without_self "Child should be Entity or Nil (#{child})!", ObjectModel unless child.is_a?(Entity) or child == nil
		raise_without_self "Forbiden to add self as Child!", ObjectModel if child == entity
		raise_without_self "Forbiden to add the same Child twice!", ObjectModel if child.parent == entity
		
		name.should! :be_a, Symbol
		
		old_parent = child.parent
		if old_parent != nil # :move
			AnEntity::EntityType.delete_from_parent child, old_parent			
			@transaction.event_processor.fire_before child, :move, entity, old_parent
			@transaction.copies[entity.entity_id].moved!
		end
		
		@transaction.event_processor.fire_before child, :new_parent, entity				
		
		child._parent = entity
		
		@transaction.event_processor.fire_after child, :new_parent, old_parent				
		
		if old_parent != nil # :move
			@transaction.event_processor.fire_after child, :move, entity, old_parent
		end		
	end
	
	def before_delete_child entity, name, child
		child.should! :be_a, Entity
		entity.should! :be_a, Entity
		name.should! :be_a, Symbol		
		
		@transaction.event_processor.fire_before child, :delete_parent, entity
		child._parent = nil
		@transaction.event_processor.fire_after child, :delete_parent, entity
	end
	
	def before_delete entity		
		if entity.name_get == "child2"
			copy = @transaction.copies[entity.entity_id]
			
			parent = entity.parent
			parent.should! :be_a, [Entity, NilClass]
			
			@transaction.deleted_entities[entity.entity_id] = entity
			
			AnEntity::EntityType.delete_all_references_to @transaction, entity
			AnEntity::EntityType.delete_from_parent entity, parent if parent		
			AnEntity::EntityType.delete_all_children entity
			return
		end
		
		copy = @transaction.copies[entity.entity_id]
		copy.should_not! :deleted?
		
		parent = entity.parent
		parent.should! :be_a, [Entity, NilClass]
		
		@transaction.deleted_entities[entity.entity_id] = entity
		
		AnEntity::EntityType.delete_all_references_to @transaction, entity
		AnEntity::EntityType.delete_from_parent entity, parent if parent		
		AnEntity::EntityType.delete_all_children entity
	end		
	
	def before_delete_reference entity, name, reference
		entity.should! :be_a, Entity
		reference.should! :be_a, Entity
		name.should! :be_a, Symbol
		
		@transaction.event_processor.fire_before reference, :delete_referrer, entity
		
		AnEntity::EntityType.delete_backreference @transaction, entity, reference		
		
		@transaction.event_processor.fire_after reference, :delete_referrer, entity
	end
	
	def before_new_reference entity, name, reference
		entity.should! :be_a, Entity
		reference.should! :be_a, Entity
		name.should! :be_a, Symbol
		
		@transaction.event_processor.fire_before reference, :new_referrer, entity
		
		AnEntity::EntityType.new_backreference @transaction, entity, reference		
		
		@transaction.event_processor.fire_after reference, :new_referrer, entity
	end	
	
	protected
	def check_name_uniquity entity, name				
		# Uniquity In Transaction Scope
		the_same = @transaction.new_entities.values.any? do |e|
			next if e == entity
			e.name == name and e.parent == entity.parent
		end		
		
		# Uniquitey In Database		
		parent = entity.parent
		parent_path = parent != nil ? parent.path + "/" : ""
		absolute_path = "#{parent_path}#{name}"		
		the_same ||= @transaction.repository.include? absolute_path
		
		raise_without_self "Not unique name '#{name}' (Parent '#{entity.parent}')!", ObjectModel if the_same
	end
end