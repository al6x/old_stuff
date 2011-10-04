class StreamWrapper
	attr_accessor :stream_id
	
	def initialize repository, stream_id; @repository, @stream_id = repository, stream_id end
	
	def each &block
		@repository.stream_read_each @stream_id, &block
	end				
end