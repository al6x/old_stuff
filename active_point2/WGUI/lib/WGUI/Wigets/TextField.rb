class TextField < Core::InputWiget
	attr_accessor :text
	
	def initialize text=""
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
	
	def password= value
		return if @password == value
		@password = value
		refresh
	end
	
	def password?; @password end
end