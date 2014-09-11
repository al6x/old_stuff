class AtomicState
	WRITE = 'w'				
	DELETE = 'd'
	FINISHED = 'f'		
		
	def initialize fname		
		File.open(fname, 'wb'){} unless File.exist? fname        
		@state = File.open fname, 'r+b'
	end
		
	def state
		@state.seek 0
		return @state.read(1)
	end
		
	def state= state
		@state.seek 0
		@state.write state
		@state.flush
	end
		
	def close; @state.close end
end