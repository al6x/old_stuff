class FileWrapper			
	def initialize path; @path = path end
		
	def each	
		File.open(@path, 'rb') do |file|			
			while part = file.read(ResourceData::BUFFER)
				yield part
			end
		end
	end				
end