class OutdatedError < RuntimeError
	attr_reader :outdated
	
	def initialize outdated
		super()
		@outdated = outdated
	end    
end