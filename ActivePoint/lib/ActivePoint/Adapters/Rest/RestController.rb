module RestController
	inherit Services::Security::SecureMethods	
	
	attr_reader :object		
	
	def initialize object
		@object = object
	end
end