class DateView < WLabel 
	include Editor    
	
	def value= date	
		@value = date		
		if @value
			year, month, day = @value.year.to_s, @value.month.to_s, @value.day.to_s
			
			month = "0" + month if month.size < 2
			day = "0" + day if day.size < 2
			
			self.text = to_l("\#{year}/\#{month}/\#{day}", binding)
		else
			self.text = ""
		end
	end
	
	def value
		@value
	end
end