class Multiselect < Core::InputWiget	
	attr_reader :values, :selected, :modify
	
	def initialize values = [], selected = []
		@values = values
		@selected = selected if selected
		@modify = false
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
	
	def update_value value		
		@selected = value.is_a?(Array) ? value : [value]
	end
	
	def modify= value
		return if @modify == value
		@modify = value
		refresh
	end
end