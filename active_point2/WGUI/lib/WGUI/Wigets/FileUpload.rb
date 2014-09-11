class FileUpload < Core::InputWiget
	attr_reader :file, :resource_id, :extension
	
	def update_value value			
		file_name = value[:filename]				
		if file_name && !file_name.empty?
			file = value[:tempfile]
			@file = Core::IO::IOWrapper.new file
			@resource_id, @extension = file_name, File.extname(file_name).split('.').last
		else 
			@file, @resource_id, @extension = nil, nil, nil
		end				
		refresh
	end	
	
	def empty?; 
		@resource_id == nil
	end
end