class Multiselect < Core::InputWiget	
	attr_reader :values, :modify
	EMPTY_SELECTION = "__empty_selection__" # Hack for empty selection
	
	MIN, MAX = 5, 10
	
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
#		values = value.is_a?(Array) ? value : [value]
#		values.should! :include?, EMPTY_SELECTION
#		values.delete EMPTY_SELECTION
		@selected = value.split("\n")
	end
	
	def modify= value
		return if @modify == value
		@modify = value
		refresh
	end
	
	def selected
		@selected
	end
	
	protected
	def select_size
		size = values.size
		size = MIN if values.size < MIN
		size = MAX if values.size > MAX
		return size
	end
end