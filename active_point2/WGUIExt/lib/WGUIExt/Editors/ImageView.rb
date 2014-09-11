class ImageView < WImage 
	include Editor
	
	def value= stream_id
		if stream_id
			@value = stream_id
			rd = WGUIAdapters::ResourceHelper.resource_data Utils::Extension.get_data_storage, stream_id
			self.data = rd
		else
			@value, self.data = nil
		end
	end			
	
	def value
		return @value
	end		
end