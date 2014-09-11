class Session
	extend Managed
	scope :session
	inject :window => Window		
	
	attr_accessor :state, :uri
end		