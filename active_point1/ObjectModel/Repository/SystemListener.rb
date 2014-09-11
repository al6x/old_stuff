class SystemListener
	def initialize transaction
		@transaction = transaction
		@deleted_parents = {}
	end
	
	def before_attribute_update entity, name, new, old
		name.should! :be_a, Symbol
		AnEntity::EntityType.validate_attribute entity, name, new, old
	end
	
	def before_entity_id_update entity, new, old		
		raise_without_self "entity_id '#{new}' should be a String!", ObjectModel unless new.is_a? String
		raise_without_self "entity_id '#{new}' shouldn't be Emtpy!", ObjectModel if new.empty?
		raise_without_self "entity_id '#{new}' should not include '/' Symbol!", ObjectModel if new.include? '/'
		
		check_entity_id_uniquity entity, new		
	end
	
	def after_new_parent entity, old_parent
		check_entity_id_uniquity entity, entity.entity_id
	end
	
	def after_delete_parent entity, old_parent
		check_entity_id_uniquity entity, entity.entity_id
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
			@transaction.copies[entity.om_id].moved!
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
		parent = entity.parent
		parent.should! :be_a, [Entity, NilClass]
		
		@transaction.deleted_entities[entity.om_id] = entity
		
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
	def check_entity_id_uniquity entity, entity_id
		return if entity.entity_id == entity_id
		
		# Uniquity In Transaction Scope
		the_same = @transaction.new_entities.values.any? do |e|
			next if e == entity
			e.entity_id == entity_id and e.parent == entity.parent
		end		
		
		# Uniquitey In Database		
		parent = entity.parent
		parent_path = parent != nil ? parent.entity_path + "/" : ""
		absolute_path = "#{parent_path}#{entity_id}"		
		the_same ||= @transaction.repository.include? absolute_path
			
		raise_without_self "Not unique entity_id '#{entity_id}' (Parent '#{entity.parent}')!", ObjectModel if the_same
	end
end