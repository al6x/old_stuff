module RubyExt
	class FileSystemProvider
		attr_accessor :base_dir
		
		def initialize base_dir = File.expand_path('.')
			@base_dir, @files, @cache = base_dir, {}, {}		
		end
		
		def class_get class_name
			if File.exist? class_to_file(class_name)
				return File.read(class_to_file(class_name))
			else
				dir = class_to_basefile(class_name)
				if File.exist? dir 
					return "module #{File.basename(dir)}; end;"
				end
			end				 
			raise Resource::NotExist
		end
		
		def class_set class_name, data
			path = class_to_file(class_name)
			File.write(path, data)
			remember_file path
		end
		
		def class_exist? class_name
			File.exist?(class_to_file(class_name)) or
			File.exist?(class_to_basefile(class_name))
		end
		
		def class_delete class_name
			path = class_to_file(class_name)
			File.delete path if File.exist? path
		end
		
		#		def class_namespace_exist? namespace_name
		#			File.exist? class_to_basefile(namespace_name)
		#		end
		
		# First search for "./class_name.resource_name" files
		# And then search for "./class_name.res/resource_name" files
		def resource_get class_name, resource_name
			path = "#{class_to_basefile(class_name)}.#{resource_name}"
			data, readed = nil, false
			if File.exist? path
				data = File.read path
				readed = true
			else
				path = "#{class_to_basefile(class_name)}.res/#{resource_name}"
				if File.exist? path
					data = File.read path
					readed = true
				end
			end
			raise Resource::NotExist unless readed					
			return data
		end
		
		def resource_delete class_name, resource_name
			path = "#{class_to_basefile(class_name)}.#{resource_name}"
			if File.exist? path
				File.delete path
			else
				path = "#{class_to_basefile(class_name)}.res/#{resource_name}"
				File.delete path if File.exist? path
			end
		end
		
		# First search for the same resource and owerwrites it
		# If such resource doesn't exists writes to
		# "./class_name.res/resource_name" file.
		def resource_set class_name, resource_name, data
			path = "#{class_to_basefile(class_name)}.#{resource_name}"
			if File.exist? path
				length = File.write path, data
			else
				dir = "#{class_to_basefile(class_name)}.res"
				FileUtils.mkdir dir unless File.exist? dir
				path = "#{dir}/#{resource_name}"
				length =  File.write path, data
			end
			remember_file path
			return length
		end
		
		def resource_exist? class_name, resource_name
			path = "#{class_to_basefile(class_name)}.#{resource_name}"
			if File.exist? path
				return true
			else
				path = "#{class_to_basefile(class_name)}.res/#{resource_name}"
				if File.exist? path
					return true
				else
					false
				end
			end
		end
		
		
		def check_for_changed_files
			changed = []
			Dir.glob("#{base_dir}/**/**").each do |path|
				if file_changed? path
					remember_file path
					changed << file_changed(path)							
				end
			end
			return changed
		end
		
		def reset_changed_files
			@files = {}
			Dir.glob("#{base_dir}/**/**").each do |path|
				remember_file path
			end
		end
		
		# Different Providers can use different class path interpretation.
		# So we return virtual path only if this path really exist.
		def class_to_virtual_file class_name
			result = nil
			if @cache.include? class_name
				result = @cache[class_name]
			else
				result = nil
				path = class_to_basefile class_name
				if File.exist? path
					result = path
				else
					path2 = "#{path}.rb"
					if File.exist? path2
						result = path
					else
						path3 = "#{path}.res"
						if File.exist? path3
							result = path			
						end
					end				
				end
				@cache[class_name] = result
			end						
			
			if result
				return "#{result}.rb"
			else
				raise Resource::NotExist, "Class '#{class_name}' doesn't Exist!"
			end								
		end
				
#		def class_to_virtual_path class_name
#			result = nil
#			if @cache.include? class_name
#				result = @cache[class_name]
#			else
#				result = nil
#				path = "#{base_dir}/#{class_name.gsub("::", "/")}"
#				if File.exist? path
#					result = path
#				else
#					path2 = "#{path}.rb"
#					if File.exist? path2
#						result = path
#					else
#						path3 = "#{path}.res"
#						if File.exist? path3
#							result = path			
#						end
#					end				
#				end
#				@cache[class_name] = result
#			end						
#			
#			if result
#				return result
#			else
#				raise Resource::NotExist, "Class '#{class_name}' doesn't Exist!"
#			end
#		end
		
		protected	
		def class_to_file class_name			
			"#{class_to_basefile(class_name)}.rb"			
		end
		
		# Different Providers can use different class path interpretation.
		# So we return virtual path only if this path really exist.
		def class_to_basefile class_name
			return "#{base_dir}/#{class_name.gsub("::", "/")}"
		end
		
		def remember_file path
			@files[path] = File.mtime(path)
		end
		
		def file_changed? path
			old_time = @files[path]
			old_time == nil or old_time != File.mtime(path)
		end
		
		def file_changed path
			begin
				if path =~ /\.rb$/
					path = path.sub(/\.rb$/, "")
					class_name = path_to_class(path)
					
					# ClassLoader.reload_class()
					klass = eval class_name, TOPLEVEL_BINDING, __FILE__, __LINE__
					@cache.delete class_name
					return :class, klass, nil
				else
					if path =~ /\.res/
						class_path = path.sub(/\.res.+/, "")
						resource_name = path.sub("#{class_path}.res/", "")
						class_name = path_to_class class_path
					else
						resource_name = path.sub(/.+\./, "")
						class_name = path_to_class path.sub(/\.#{resource_name}$/, "")
					end			
					klass = eval class_name, TOPLEVEL_BINDING, __FILE__, __LINE__
					return :resource, klass, resource_name			
				end
			rescue Exception => e
				p "Can't reload file '#{path}' #{e.message}!"																				
			end
		end
		
		def path_to_class path
			path.gsub(/^#{base_dir}\//, "").gsub("/", "::")
		end
		
		#			Doesn't make Sense for Virtual Resource System
		#			def resource_path class_name, resource_name
		#				@monitor.synchronize do
		#					path = "#{class_to_path(class_name)}.#{resource_name}"
		#					if File.exist? path
		#						return path
		#					else
		#						path = "#{class_to_path(class_name)}.res/#{resource_name}"
		#						if File.exist? path
		#							return path
		#						else
		#							nil
		#						end
		#					end
		#				end
		#			end
		
	end
end