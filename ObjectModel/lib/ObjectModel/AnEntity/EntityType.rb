class EntityType
	class << self
		inherit Log
		
		def initialize_storage db			
			db.create_table :entities do
				column :entity_id, :text
				column :name, :text
				column :class, :text
				
				column :om_version, :text				
				column :parent_id, :text
				
				primary_key :entity_id
#				index :entity_id
			end
			
			db.create_table :entities_content do
				column :entity_id, :text
				
				column :name, :text
				
				column :value, :text				
				column :class, :text
				
				primary_key :entity_id, :attr_name, :key
#				index :entity_id
			end						
		end
		
		def print_storage db, name
			if name == nil or name == :entities
				puts "\nEntities:"
				db[:entities].print
			end
			if name == nil or name == :entities_content
				puts "EntitiesContent:"
				db[:entities_content].print
			end
		end
		
		def create_copy e
			e.entity_id.should_not! :be_nil
			
			c = EntityCopy.new
			c.om_version, c.entity_id, c.name = e.om_version, e.entity_id, e.name
			c.parent = e.instance_variable_get "@parent"
			c.updated!						
			
			# Attributes
			e.meta.attributes.each do |n, m|
				m.type.initialize_copy m, e, c
			end
			
			# Children
			e.meta.children.each do |n, m|
				m.type.initialize_copy m, e, c
			end
			
			# References
			e.meta.references.each do |n, m|
				m.type.initialize_copy m, e, c
			end			
			
			BackReferences.initialize_copy e, c						
			
			return c
		end
		
		def initialize_new_entity e, eid, entity_id, tr
			new_entity_id = if entity_id
				entity_id.should! :be_a, String
				#				path_index = tr.repository._index_manager.get_index_without_transaction_check(:path)
				#				path_index.get_entity_id(entity_id).should! :be_nil								
				raise_without_self "Not Unique :entity_id ('#{entity_id}')!", ObjectModel if storage_include? entity_id, tr.repository.storage
				
				tr.copies.should_not! :include, entity_id
				entity_id
			else
				tr.repository.storage.generate(:entity_id)
			end
			
			unless eid
				eid = "eid_" + tr.repository.storage.generate(:name)
			end
			
			e.instance_variable_set "@entity_id", new_entity_id						
			e.instance_variable_set "@om_repository", tr.repository
			e.instance_variable_set "@om_version", 0
			
			# Attributes
			e.meta.attributes.each do |n, m|				
				value = m.type.initial_value m, e
				e.instance_variable_set m.ivname, value
			end
			
			# Children
			e.meta.children.each do |n, m|
				value = m.type.initial_value m, e
				e.instance_variable_set m.ivname, value
			end
			
			# References
			e.meta.references.each do |n, m|
				value = m.type.initial_value m, e
				e.instance_variable_set m.ivname, value
			end						
			
			BackReferences.initialize_entity e
			
			tr.event_processor.fire_before e, :new
			
			e.name = eid # after :new
		end
		
		def load entity_id, repository, storage
			entity_id.should! :be_a, String
			row = storage[:entities][:entity_id => entity_id]
			unless row
				raise NotFoundError, "Entity with entity_id '#{entity_id}' not found!"
				#				raise_without_self NotFoundError, "Entity with Path '#{path}' not found!", ObjectModel 
			end
			
			# Entity
			klass_name = row[:class]
			begin
				klass = eval klass_name, TOPLEVEL_BINDING, __FILE__, __LINE__
				e = klass.new nil, nil, "original_new"
				e.should! :be_a, Entity
			rescue NameError => err
				log.error "Can't find '#{klass}' Class for '#{entity_id}' Entity!"
				raise LoadError.new(err)
			end		
			
			e.instance_variable_set "@entity_id", entity_id
			e.instance_variable_set "@name", row[:name].should_not!(:be_nil).should_not!(:be_empty)
			e.instance_variable_set "@om_version", row[:om_version].should_not!(:be_nil).to_i
			e.instance_variable_set "@parent", load_id(row[:parent_id].should_not!(:be_nil))
			e.instance_variable_set "@om_repository", repository
			
			outdated = []
			
			# Attributes
			e.meta.attributes.each do |n, m|
				value = begin
					m.type.load m, e, storage						
				rescue LoadError
					outdated << n
					log.warn "Can't load '#{entity_id}.#{n}' Attribute, default value will be used!"
					value = m.type.initial_value m, e
					e.instance_variable_set m.ivname, value
				end
			end						
			
			# Children
			e.meta.children.each do |n, m|
				value = begin
					m.type.load m, e, storage					
				rescue LoadError
					log.warn "Can't load '#{entity_id}.#{n}' Child, default value will be used!"
					value = m.type.initial_value m, e
					e.instance_variable_set m.ivname, value
				end
			end
			
			# References
			e.meta.references.each do |n, m|
				value = begin
					m.type.load m, e, storage
				rescue LoadError
					log.warn "Can't load '#{entity_id}.#{n}' Reference, default value will be used!"					
					value = m.type.initial_value m, e
					e.instance_variable_set m.ivname, value
				end				
			end
			
			# BackReferences
			BackReferences.load e, storage			
			
			# Data Migration
			custom_initialization e, outdated if outdated.size > 0
			
			return e
		end
		
		def storage_include? entity_id, storage
			storage[:entities][:entity_id => entity_id] != nil
		end
		
		def write_back c, e
			c.should! :be_a, EntityCopy
			
			# Entity
			c.om_version += 1
			e.instance_variable_set "@om_version", c.om_version
			e.instance_variable_set "@parent", c.parent
			e.instance_variable_set "@name", c.name
			
			# Attributes
			e.meta.attributes.each do |n, m|
				m.type.write_back c, e, m
			end						
			
			# Children
			e.meta.children.each do |n, m|
				m.type.write_back c, e, m				
			end
			
			# References
			e.meta.references.each do |n, m|
				m.type.write_back c, e, m				
			end
			
			# BackReferences			
			BackReferences.write_back c, e
		end
		
		def persist c, e, storage
			entity_id = e.entity_id
			
			# Entity
			entities = storage[:entities]
			entities.filter(:entity_id => entity_id).delete 
			entities.insert(
											:entity_id => entity_id.should!(:be_a, String).should_not!(:be_empty),
			:name => e.name.should!(:be_a, String).should_not!(:be_empty),
			:class => e.class.name,
			:om_version => c.om_version,
			:parent_id => AnEntity::EntityType.dump_id(c.parent)
			)
			storage[:entities_content].filter(:entity_id => entity_id).delete
			
			# Attributes			
			e.meta.attributes.each do |n, m|
				m.type.persist c, entity_id, m, storage										
			end						
			
			# Children
			e.meta.children.each do |n, m|
				m.type.persist c, entity_id, m, storage				
			end
			
			# References
			e.meta.references.each do |n, m|
				m.type.persist c, entity_id, m, storage				
			end
			
			# BackReferences
			BackReferences.persist c, entity_id, storage
		end
		
		def delete e, storage
			entity_id = e.entity_id
			
			# Entity
			storage[:entities].filter(:entity_id => entity_id).delete 
			storage[:entities_content].filter(:entity_id => entity_id).delete
			
			# Attributes			
			e.meta.attributes.each do |n, m|			
				m.type.respond_to :delete, e, m, storage										
			end						
			
			# Children
			e.meta.children.each do |n, m|
				m.type.respond_to :delete, e, m, storage											
			end
			
			# References
			e.meta.references.each do |n, m|
				m.type.respond_to :delete, e, m, storage												
			end
			
			# BackReferences
			BackReferences.delete e, storage
		end
		
		def custom_initialization e, outdated = nil
			e.meta.attributes.each do |n, m|
				next if m.initialize == NotDefined or (outdated and !outdated.include?(n))
				value = if m.initialize.is_a? Proc
					e.instance_eval &m.initialize
				else
					m.initialize
				end
				e.send m.name.to_writer, value 
			end
		end
		
		def validate_attribute e, name, new, old
			m = e.class.meta.attributes[name]
			
			unless m.type.validate_type new
				raise_without_self Errors::ValidationError, 
				"Invalid Value Type '#{new}' for Attribute '#{e.class.name}.#{name}'!", 
				ObjectModel
			end
			
			v = m.validate			
			if v != nil
				v.should! :be_a, Proc
				begin
					v.call new
				rescue RuntimeError => err
					raise Errors::ValidationError, err.message, err.backtrace
				end
				#				unless v.call new
				#					raise_without_self Errors::ValidationError, 
				#					"Invalid Value '#{new}' for Attribute '#{e.class.name}.#{name}'!", 
				#					ObjectModel
				#				end
			end									
		end
		
		def validate_entity e
			begin
				e.class.meta.validation.validate e
			rescue RuntimeError => err
				raise Errors::ValidationError, err.message, err.backtrace
			end
			#			unless e.class.meta.validation.validate e
			#				raise_without_self Errors::ValidationError, 
			#				"Invalid Entity #{e}!",
			#				ObjectModel
			#			end
		end
		
		def delete_all_children e						
			e.meta.children.each do |n, m|	
				m.type.delete_all_children e, m
			end
		end
		
		def delete_all_references_to tr, e
			c = tr.copies[e.entity_id]
			processed = Set.new
			BackReferences.delete_all_references_to e, c do |referrer_entity_id|
				next if processed.include? referrer_entity_id
				processed << referrer_entity_id
				
				referrer = tr.resolve referrer_entity_id
				referrer.meta.references.each do |n, m|
					m.type.delete_all_references_to referrer, e, m
				end
			end
		end
		
		def delete_from_parent e, parent		
			e.should! :be_a, Entity
			parent.should! :be_a, Entity
			parent.meta.children.each do |n, m|
				m.type.delete_from_parent e, parent, m
			end
		end
		
		def delete_backreference transaction, entity, reference
			reference_copy = transaction.copy_get! reference
			BackReferences.delete_backreference entity, reference, reference_copy
		end
		
		def new_backreference transaction, entity, reference
			reference_copy = transaction.copy_get! reference
			BackReferences.new_backreference entity, reference, reference_copy
		end
		
		def each_attribute e, &b
			e.meta.attributes.each{|n, m| b.call e.send(n)}
		end
		
		def each_child e, &b
			e.meta.children.each{|n, m| m.type.each e, m, &b}
		end
		
		def each_reference e, &b
			e.meta.references.each{|n, m| m.type.each e, m, &b}
		end
		
		def each_entity_in_repository repository, &b
			repository.storage[:entities].each do |row|
				e = repository.by_id row[:entity_id]
				b.call e
			end
		end
		
		def load_id data			
			raise LoadError if data == nil
			data == "nil" ? nil : data
		end
		
		def dump_id id			
			if id == nil 
				"nil" 
			else
				id.should! :be_a, String
				id
			end
		end
		
		def load_id! data, klass
			raise LoadError unless klass == "ENTITY_ID"
			load_id data
		end
		
		def dump_id! id
			[dump_id(id), "ENTITY_ID"]
		end
	end		
end