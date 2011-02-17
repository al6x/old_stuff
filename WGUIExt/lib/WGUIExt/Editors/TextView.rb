class TextView < WLabel
	include Editor	
	
	def initialize
		super
		self.preformatted = true
	end
	
	alias_method :value, :text
	alias_method :value=, :text=
end