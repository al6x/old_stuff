class RichTextView < WGUIExt::RichText::View
	include Editor
		
	def value= data 
		data.should_not! :be_nil
		@value = data
		wgui_data = WGUIExt::RichText::RTData.new data.text
		wgui_data.resources = data.resources.collect do |stream_id|
			WGUIAdapters::ResourceHelper.resource_data(Utils::Extension.get_data_storage, stream_id)
		end
		self.data = wgui_data
	end
	
	def value
		@value
	end
end