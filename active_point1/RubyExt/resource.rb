module RubyExt
	module Resource		
		@monitor = Monitor.new		
		@providers = []		
		@resource_extensions = {}
		
		class NotExist < RuntimeError
			
		end
		
		class << self
			include Observable
			
			def add_resource_provider provider
				@providers.unshift provider
			end
			
			def providers
				raise "There's no any Resource Provider!" if @providers.empty?
				@providers
			end
			
			def register_resource_extension extension, load, save
				@monitor.synchronize do
					@resource_extensions[extension] = load, save
				end
			end
			
			def unregister_resource_extension extension
				@monitor.synchronize do
					@resource_extensions.delete extension
				end
			end												
			
			# Returns from first Provider that contains this Class.
			def class_get class_name
				@monitor.synchronize do
					providers.each do |p|
						begin
							return p.class_get(class_name) 
						rescue NotExist;
						end
					end
					raise "Class '#{class_name}' doesn't exist!"
				end
			end
			
			# Search for first Provider that contains Class Namespace and creates Class in it, then exits.
			def class_set class_name, data
				@monitor.synchronize do					
					namespace = Module.namespace_for class_name
					namespace = namespace ? namespace.to_s : nil
					found = true
					providers.each do |p|
						next unless !namespace or p.class_exist?(namespace)
						p.class_set class_name, data
						break
					end
					raise "Namespace '#{namespace}' doesn't exist!" unless found
				end
			end
			
			def class_exist? class_name
				@monitor.synchronize do
					providers.any?{|p| p.class_exist? class_name}
				end
			end
			
			# Deletes in each Providers.
			def class_delete class_name
				@monitor.synchronize do
					providers.each{|p| p.class_delete class_name}
				end
			end
			
#			def class_namespace_exist? namespace_name
#				@monitor.synchronize do
#					providers.any?{|p| p.class_namespace_exist? namespace_name}
#				end
#			end
			
			# Search each Provider that contains this Class and returns first found Resource.
			def resource_get klass, resource_name				
				@monitor.synchronize do					
					providers.each do |p|
						next unless p.class_exist?(klass.name)
						begin
							data = p.resource_get(klass.name, resource_name)
							
							if data
								extension = File.extname(resource_name)
								if @resource_extensions.include? extension
									load, save = @resource_extensions[extension]
									data = load.call data, klass, resource_name
								end
							end
							
							return data
						rescue NotExist;
						end
					end
					raise "Resource '#{resource_name}' for Class '#{klass.name}' doesn't exist!"
				end
			end
			
			# Deletes Resource in all Providers.
			def resource_delete klass, resource_name
				@monitor.synchronize do
					providers.each do |p|
						next unless p.class_exist?(klass.name)
						p.resource_delete klass.name, resource_name		
					end
				end
			end
			
			# Set Resource in fist Provider that contains this Class.
			def resource_set klass, resource_name, data
				@monitor.synchronize do
					extension = File.extname(resource_name)
					if @resource_extensions.include? extension
						load, save = @resource_extensions[extension]
						data = save.call data, klass, resource_name
					end
					
					found = false
					providers.each do |p|
						next unless p.class_exist?(klass.name)
						p.resource_set klass.name, resource_name, data
						found = true
						break
					end
					
					raise "Class '#{klass.name}' doesn't exist!" unless found
				end
			end
			
			# Check also for Class existence.
			def resource_exist? klass, resource_name
				@monitor.synchronize do
					providers.any? do |p|
						next unless p.class_exist?(klass.name)
						p.resource_exist? klass.name, resource_name
					end
				end
			end						
			
			def start_watching interval = 2
				stop_watching
				@watch_thread = Thread.new do
					providers.each{|p| p.reset_changed_files}
					while true
						sleep interval
						begin
							providers.each do |p| 
								p.check_for_changed_files.each do |type, klass, res|							
									notify_observers :update_resource, type, klass, res
								end
							end
						rescue Exception => e
							warn e
						end
					end
				end
			end
			
			def stop_watching
				if @watch_thread
					@watch_thread.kill
					@watch_thread = nil
				end
			end
			
			def class_to_virtual_file class_name
				@monitor.synchronize do				
					providers.each do |p|
						begin
							return p.class_to_virtual_file class_name 
						rescue NotExist;
						end
					end
					raise "Class '#{class_name}' doesn't exist!"					
				end
			end
			
#			def class_to_virtual_path class_name
#				@monitor.synchronize do
#					providers.each do |p|
#						begin
#							return p.class_to_virtual_path class_name 
#						rescue NotExist;
#						end
#					end
#					raise "Class '#{class_name}' doesn't exist!"
#				end
#			end
		end 
	end
end