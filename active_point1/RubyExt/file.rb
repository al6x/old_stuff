class File
	class << self
		def write(path, data)
			File.open(path, "wb") do |file|
				return file.write(data)
			end
		end
		
		def read(path)
			File.open(path, "rb") do |file|
				return file.read
			end
		end
		
		def create_directory dir
			Dir.mkdir dir unless File.exist? dir
		end
	end
end