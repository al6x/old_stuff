class Select < Core::InputWiget
	attr_reader :selected, :values, :modify
	
	def initialize values = [], selected = nil		
		@values = values
		@selected = selected
		@modify = false
	end
	
	def update_value value
		@selected = value
	end
	
	def selected= value
		return if @selected == value
		@selected = value
		refresh
	end
	
	def values= values
		return if @values == values
		@values = values
		refresh
	end
	
	def modify= value
		return if @modify == value
		@modify = value
		refresh
	end
end