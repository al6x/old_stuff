class Extensions	
	CONFIGURATOR_NAME = "Config"
	
	class << self
		def activate! 
			@activated = true
			list_extensions.every.activate!
		end
		
		def startup!					
			@activated.should! :be_true
			@started = true
			list_extensions.every.startup!
		end				
		
		def teardown!
			@started.should! :be_true
			list_extensions.every.teardown!
		end
		
		def clear_data!
			@activated.should! :be_true
			list_extensions.each do |c|
				c.clear_data! if c.initialized?
			end
		end
		
		def initialize_data!
			Locale.language :en do
				@activated.should! :be_true
				list_extensions.each do |c| 
					unless c.initialized?
						c.initialize_data!
					end
				end
			end
		end		
		
		def any_initialized?
			list_extensions.any?{|c| c.initialized?}
		end
		
		def restart!
			@started.should! :be_true
			list_extensions.every.restart!
		end
		
		def controller_for object_klass, adapter_sign
			object_klass = object_klass.class unless object_klass.is_a?(Module) or object_klass.is_a?(Class)
			
			object_klass.should! :be, Entity
			adapter_sign.should! :be_a, String
			
			object_klass.ancestors.each do |anc|
				next unless anc.is? Entity
				
				anc.name.should! :include?, MODEL_NAME
				name_parts = anc.name.split('::')						
				name_parts.size.should! :>, 1
				
				index = name_parts.size - 1
				name_parts.reverse_each do |npart|
					if npart == MODEL_NAME							
						class_name = name_parts.clone
						class_name[index] = adapter_sign
						class_name = class_name.join("::")
						next unless RubyExt::Resource.class_exist? class_name
						
						adapter_class = eval class_name, TOPLEVEL_BINDING, __FILE__, __LINE__							
						return adapter_class
					end
					index -= 1
				end
			end
			
			raise NameError, "No Adapter class for '#{object_klass.name}' Entity Object!"
		end
		
		protected
		def list_extensions
			parser = lambda{|memo, key| memo + CONFIG[key].should!(:be_a, Array)}
			core = [:core_adapters, :core_services, :core_plugins].inject([], &parser)
			external = [:adapters, :services, :plugins].inject([], &parser)
			
			core = sort_dependencies core
			external = sort_dependencies external
			(core & external).should! :==, []
			
			return core + external
		end
		
		def sort_dependencies extensions
			sorted = []
			extensions.each do |ext|
				_sort_dependencies ext, sorted, Set.new
			end			
			return sorted
		end		
		
		def _sort_dependencies ext, sorted, processed			
			conf = configurator_for ext
			
			if processed.include?(ext) and !sorted.include?(conf)
				raise "Circular dependencies between '#{ext}' and some another Extension!" 
			end
			processed << ext
			
			conf.depends_on.each do |dext|
				_sort_dependencies dext, sorted, processed
			end
			
			sorted << conf unless sorted.include? conf
		end
		
		def configurator_for extension_class
			return extension_class if extension_class.is_a? Configurator
			begin
				eval "#{extension_class}::#{CONFIGURATOR_NAME}", TOPLEVEL_BINDING, __FILE__, __LINE__				
			rescue NameError => e
				ActivePoint.log.error "Invalid Configurator for #{extension_class.name} Extension!"
				raise e
			end
		end
	end
end