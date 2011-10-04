class StaticResource
	extend Managed
	scope :application
	
	EXPIRES = 3600*48
	
	def initialize
		super
		@paths, @files = [], {}
	end
	
	def add_path path
		File.exist?(path).should! :be_true
		
		@paths << path unless @paths.include? path
	end
	
	def add_file file, path
		file.should! :be_a, String
		Path.new(file).should! :relative?
		File.exist?(path).should! :be_true
		
		@files[file] = path
	end
	
	# Synchronization not needed, there is no shared state.
	def get_static_resource resource_path				
		resource_path.should! :relative?
		fname = lookup_resource resource_path
		unless fname
			raise "File '#{resource_path}' not found!" 
		end				
		
		res = Core::IO::ResourceData.initialize_from_file fname
		h = header(fname, res)		 
		return res, h
	end
	
	protected
	def header fname, res
		header = {
				"Content-Type" => res.mime_type, 
				"Content-Length" => res.size.to_s,
		}		
		set_date! header unless $debug
		header_fname = "#{fname}.header.yaml"
		if File.exist? header_fname
			File.open(header_fname) do |f|
				custom_header = YAML.load f.read
				header.merge! custom_header
			end
		end
		header
	end
	
	def set_date! header
		t = Time.new
#		header["Max-Age"] = EXPIRES.to_s
#		header["Age"] = "#{TIMEOUT*1000}"
#		header["Date"] = t.httpdate
#		header["Last-Modified"] = t.httpdate
		header["Expires"] = (t + EXPIRES).httpdate
		header["Cache-control"] = "public"
	end
	
	def lookup_resource resource_path
		fname = @files[resource_path]
		unless fname
			@paths.each do |path|
				try = File.join(path, resource_path)
				if File.exists? try
					fname = try
					break
				end
			end
		end				
		return fname
	end
end