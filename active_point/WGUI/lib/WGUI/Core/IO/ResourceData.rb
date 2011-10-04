class ResourceData
	include OpenConstructor
	attr_accessor :resource_id, :size, :extension, :wrapper	
		
	def initialize resource_id, wrapper, size, extension
		@resource_id, @wrapper, @size, @extension = resource_id, wrapper, size, extension
	end
		
	BUFFER = 8192
		
	File.open(File.join(File.dirname(__FILE__),"mime.yaml")) do |file|
		MIME_TYPES = YAML.load(file)
	end	
		
	def mime_type
		return MIME_TYPES[extension] || "application/octet-stream"
	end
		
	def each &block
		@wrapper.each(&block)
	end		
		
	def self.initialize_from_file path
		ResourceData.new(
			File.basename(path),
			FileWrapper.new(path),
			File.size(path),
			File.extname(path).split('.').last
		)
	end
end