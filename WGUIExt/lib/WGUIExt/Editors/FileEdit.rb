class FileEdit < WComponent
	include Editor
	
	children :@file_view, :@file_edit
	
	def value= stream_id
		@stream_id = stream_id
	end		
	
	def build  				
		if @stream_id
			@file_view = WResource.new
			rd = WGUIAdapters::ResourceHelper.resource_data Utils::Extension.get_data_storage, @stream_id
			@file_view.data = rd
		else
			@file_view = nil
		end
		
		@file_edit = WFileUpload.new
	end
	
	def value
		@stream_id = WGUIAdapters::ResourceHelper.upload(Utils::Extension.get_data_storage, @file_edit) unless @file_edit.empty?
		return @stream_id
	end
end