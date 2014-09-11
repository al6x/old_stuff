class RichTextEdit < WGUIExt::RichText::Editor
	include Editor 
	
	def value= data 	
		data.should! :be_a, RichTextData
		@data = WGUIExt::RichText::RTData.new data.text
		@data.resources = data.resources.collect do |stream_id|
			WGUIAdapters::ResourceHelper.resource_data(Utils::Extension.get_data_storage, stream_id)
		end
				
		on_add do |upload|
			unless upload.empty?
				stream_id = WGUIAdapters::ResourceHelper.upload(Utils::Extension.get_data_storage, upload)
				rd = WGUIAdapters::ResourceHelper.resource_data(Utils::Extension.get_data_storage, stream_id)
				@data.resources << rd
			end
		end
		on_delete do |resource_data|
			@data.resources.delete resource_data
		end
	end
	
	def value
		save
		ogdata = RichTextData.new
		ogdata.text = @data.text
		ogdata.resources = @data.resources.collect{|rd| rd.wrapper.stream_id}
		return ogdata
	end
end