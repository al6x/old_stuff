class Label < Core::Wiget
	attr_reader :text, :preformatted, :no_escape		
	
	def initialize text = ""
		super()
		@text = text
		@preformatted = false
	end 
	
	def text= text
		return if @text == text		
		@text = text
		refresh
	end
	
	def preformatted= value
		return if @preformatted == value
		@preformatted = value
		refresh
	end
	
	def no_escape= value
		return if @no_escape == value
		@no_escape = value
		refresh
	end
end	