class StreamStorage
	STREAMS = "streams"
	
	def initialize name, basedir, buffer_size = 8192
		@buffer_size = buffer_size
		raise "Invalid directory '#{basedir}'!" unless File.exist? basedir           
		@path = File.join(basedir.gsub("\\", '/'), name.to_s)
		
		Dir.mkdir @path unless File.exist? @path						
		Dir.mkdir File.join(@path, STREAMS) unless File.exist? File.join(@path, STREAMS)                
	end        
	
	def clear
		FileUtils.rm Dir.glob(File.join(@path, STREAMS, "*.dat"))		
	end
	
	def strip_id id
		id.sid
	end
	
	def metadata_put id, metadata
		id = strip_id(id)
		metafile_name = File.join(@path, STREAMS, "#{id.to_s}.met")
		File.open(metafile_name, "wb") do |datafile|			
			datafile.write YAML.dump(metadata)
		end						
	end
	
	def metadata_read id
		id = strip_id(id)
		begin
			File.open(File.join(@path, STREAMS, "#{id.to_s}.met"), "rb") do |file|
				return YAML.load(file.read)
			end
		rescue Exception => e
			if e.message =~ /No such file or directory/
				raise RuntimeError, "The Metadata with id '#{id}' not exist!", caller
			else
				raise e
			end
		end
	end
	
	def stream_put id, data = nil, &block		
		id = strip_id(id)
		datafile_name = File.join(@path, STREAMS, "#{id.to_s}.dat")
		File.open(datafile_name, "wb") do |datafile|
			if block
				block.call datafile
			elsif data
				datafile.write data
			else
				raise "Data is not supplied!"
			end				
		end		
	end
	
	def stream_put_each id, stream
		stream_put id do |out|
			while part = stream.read(@buffer_size)
				out.write part
			end
		end		
	end
	
	def stream_read id, &block
		id = strip_id(id)
		begin
			File.open(File.join(@path, STREAMS, "#{id.to_s}.dat"), "rb") do |file|
				if block
					block.call file
				else
					return file.read
				end
			end
		rescue Exception => e
			if e.message =~ /No such file or directory/
				raise RuntimeError, "The Stream with id '#{id}' has been deleted!", caller
			else
				raise e
			end
		end
	end
	
	def stream_read_each id, &block
		stream_read id do |f|
			while part = f.read(@buffer_size)
				block.call part
			end
		end
	end
	
	def stream_size id
		id = strip_id(id)
		name = File.join(@path, STREAMS, "#{id.to_s}.dat")		
		raise RuntimeError, "The Stream with id '#{id}' has been deleted!", caller unless File.exist? name
		File.size(name)
	end
	
	def size
		Dir.glob(File.join(@path, STREAMS, "*.dat")).size 
	end
	
	def delete id
		id = strip_id(id)
		name = File.join(@path, STREAMS, "#{id.to_s}.dat")		
		File.delete name if File.exist? name
		
		name = File.join(@path, STREAMS, "#{id.to_s}.met")		
		File.delete name if File.exist? name
	end
	
	def list_of_ids
		Dir.glob(File.join(@path, STREAMS, "*.dat")).collect{|name| File.basename(name, ".dat")}
	end
	
	def self.delete name, basedir
		path = File.join(basedir, name.to_s)
		FileUtils.rm_rf path if File.exist? path
	end	
end