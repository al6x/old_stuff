class TextArea < Core::InputWiget		
	attr_reader :text
	
	def initialize text = ""
		super()
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