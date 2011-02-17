class Checkbox < Core::InputWiget	
	attr_reader :selected
	
	def initialize selected = false
		@selected = selected
	end
	
	def update_value new_value; 
		@selected = new_value == "true"
	end
	
	def selected= value			
		return if @selected = value
		@selected = value
		refresh
	end
end