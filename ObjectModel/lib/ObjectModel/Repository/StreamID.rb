class StreamID
	attr_reader :sid
	def initialize id = nil
		@sid = id
	end
	
	def == other
		return false unless other.respond_to? :sid
		@sid == other.sid
	end
	
	def eql? other
		return false unless self.class == other.class
		@sid == other.sid
	end
	
	def hash		
		return @sid.hash
	end		
end