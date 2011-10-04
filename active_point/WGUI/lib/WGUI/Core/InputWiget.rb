class InputWiget < Wiget	
#	def update_value new_value; end Override it
		
	def disabled?; 
		@disabled = false if @disabled == nil
		@disabled
    end
	
	def disabled= value
		@disabled = value
		refresh
    end
end