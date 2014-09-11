class NumberEdit < WTextField	
	include Editor
	
	attr_accessor :type
	
	def value= value
		self.text = value.to_s		
		end
	
	def value
		text = self.text.strip
		case type
			when :integer then
				return Integer(text)
			when :float then
				return Float(text)
		else			
			value = Float(text)
			return value if value.to_s == text
			return Integer(text)
		end
	end
end