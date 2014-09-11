class BooleanView < WCheckbox
	include Editor
	
	def initialize
		super
		self.disabled = true;
	end
	
	alias_method :value, :selected
	alias_method :value=, :selected=
end