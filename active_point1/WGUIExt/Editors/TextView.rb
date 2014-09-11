class TextView < WLabel
	include Editor	
	
	def initialize
		super
		self.noformat = true
	end
	
	alias_method :value, :text
	alias_method :value=, :text=
end