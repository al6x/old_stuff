class Label < Core::Wiget
	attr_reader :text, :noformat		
	attr_writer :style
	
	def initialize text = ""
		super()
		@text = text
		@noformat = false
	end 
	
	def text= text
		return if @text == text		
		@text = text
		refresh
	end
	
	def noformat= value
		return if @noformat == value
		@noformat = value
		refresh
	end
end	