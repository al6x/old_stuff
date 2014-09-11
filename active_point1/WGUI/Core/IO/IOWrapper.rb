class IOWrapper
	def initialize io; @io = io end
		
	def each				
		@io.rewind
		while part = @io.read(ResourceData::BUFFER)
			yield part
		end
	end
end