class ResourceHelper
	class << self
		def upload storage, upload
			return nil unless upload and !upload.empty?
			
			stream_id = storage.stream_put do |out|                
				upload.file.each{|part| out.write part}                                                
			end
			
			storage.stream_metadata_put(stream_id, {
				:resource_id => upload.resource_id, 
				:size => storage.stream_size(stream_id), 
				:extension => upload.extension                
			})
			
			return stream_id
		end
		
		def upload_from_file storage, file			
			stream_id = storage.stream_put_from_file file
			
			storage.stream_metadata_put(stream_id, {
				:resource_id => File.basename(file, ".*"), 
				:size => File.size(file), 
				:extension => File.extname(file)       
			})
			
			return stream_id
		end
		
		def resource_data storage, stream_id
			sw = WGUIAdapters::StreamWrapper.new storage, stream_id
			metadata = storage.stream_metadata_read stream_id
			WResourceData.new metadata[:resource_id], sw, metadata[:size], metadata[:extension]
		end
	end
end