class TextArea < Core::InputWiget		
	attr_reader :text
	
	def initialize text = ""
		@text = text
	end
	
	def update_value value
		@text = value
	end
	
	def text= value		
		return if @text == value
		@text = value
		refresh
	end
end