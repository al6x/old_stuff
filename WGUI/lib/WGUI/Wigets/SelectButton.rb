class SelectButton < Core::Wiget	
	include Core::ExecutableWiget
	
	attr_reader :selected
	
	def selected= value
		return if @selected == value
		@selected = value
		refresh
	end
end