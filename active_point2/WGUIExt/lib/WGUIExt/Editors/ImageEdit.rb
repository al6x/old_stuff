class ImageEdit < WComponent
	include Editor
	
	children :@image_view, :@image_edit
	
	def value= stream_id
		@stream_id = stream_id
	end		
	
	def build  				
		if @stream_id
			@image_view = WImage.new
			rd = WGUIAdapters::ResourceHelper.resource_data Utils::Extension.get_data_storage, @stream_id
			@image_view.data = rd
		else
			@image_view = nil
		end
		
		@image_edit = WFileUpload.new
	end
	
	def value
		@stream_id = WGUIAdapters::ResourceHelper.upload(Utils::Extension.get_data_storage, @image_edit) unless @image_edit.empty?
		return @stream_id
	end
end