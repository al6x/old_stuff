class Stub < WLabel
	extend Managed
	scope :session
	
	def initialize
		super "Stub"
	end
end