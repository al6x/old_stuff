class ObjectType
	class << self
		def initial_value m, e
			e.instance_variable_set m.ivname, nil
		end
		
		def initialize_storage db			
			db.create_table :value_objects do
				column :om_id, :text
				column :name, :text 
				column :yaml, :text						
			end
		end
		
		def initialize_copy m, e, c			
			value = e.instance_variable_get(m.ivname)
			value_copy = if value == nil
				nil
			elsif value.respond_to? :copy
				value.copy
			else
				copy_object value
			end
			c[m.ivname] = value_copy
		end
		
		def write_back c, e, m				
			value = c[m.ivname]
			freeze_all_tree value
			e.instance_variable_set m.ivname, value
		end
		
		def persist c, om_id, m, storage			
			storage[:value_objects].filter(:om_id => om_id, :name => m.name.to_s).delete
			value = YAML.dump c[m.ivname]			
			storage[:value_objects].insert(
																		:om_id => om_id, 
																		:name => m.name.to_s,
																		:yaml => value
			)			
		end
		
		def delete e, m, storage					
			storage[:value_objects].filter(:om_id => e.om_id, :name => m.name.to_s).delete
		end
		
		def load m, e, storage	
			row = storage[:value_objects][:om_id => e.om_id, :name => m.name.to_s]
			raise LoadError unless row
			
			value = yaml_load row[:yaml] #YAML.load row[:yaml] # YAML doesn't raise ConstMissing, so we can't just load.
						
			freeze_all_tree value
			e.instance_variable_set m.ivname, value
		end
		
		def print_storage db, name
			return unless name == nil or name == :value_objects
			puts "\nValueObjects: size = #{db[:value_objects].size}"
			#			db[:value_objects].print
		end
		
		def validate_type value
			!(value.is_a?(Entity) or value.is_a?(Proc))
		end
		
		protected				
		def freeze_all_tree value, processed = Set.new
			case value
				when String then
				value.freeze
				return
			else
				return if processed.include? value.object_id
				processed << value.object_id
				
				value.freeze
				value.instance_variables.each do |ivname|
					iv = value.instance_variable_get ivname
					ObjectType.freeze_all_tree iv, processed
				end
				
				if value.respond_to? :each
					value.each do |o|
						ObjectType.freeze_all_tree o, processed
					end
				end
			end						
		end
		
		def copy_object object
			Marshal.load(Marshal.dump(object))
		end
		
		# Becouse YAML don't raise ConstMissing error we need to preload all Classes from YAML data.
		def yaml_load data
			doc = YAML.parse data
			load_classes_for doc
			o = doc.transform
			return o
		end
		
		PRELOADED_TYPES = %w{object hash map array seq}
		def load_classes_for doc, processed = []
			return if !doc or processed.include?(doc)
			processed << doc
			
			return unless doc.type_id
			
			info = doc.type_id.split(':', 4) 
			type, klass = info[2], info[3]
			eval(klass, TOPLEVEL_BINDING) if PRELOADED_TYPES.include? type
			if doc.value.is_a? Hash			
				doc.value.each { |k,v|
					load_classes_for v, processed
				}
			elsif doc.value.is_a? Array
				doc.value.each { |v|
					load_classes_for v, processed
				}		
			else	
				#			raise
			end		
		end
	end			
end