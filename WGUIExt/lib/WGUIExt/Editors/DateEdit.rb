class DateEdit < WComponent
	include Editor
	
	children :@year, :@month, :@day
	
	def value= date	
		@value = date
		if @value
			year, month, day = @value.year.to_s, @value.month.to_s, @value.day.to_s
			
			month = "0" + month if month.size < 2
			day = "0" + day if day.size < 2						
		else
			year, month, day = "", "", ""	
		end
		@year, @month, @day = WTextField.new(year), WTextField.new(month), WTextField.new(day)		
	end
	
	def value
		if (@year.text + @month.text + @day.text).strip.empty?
			@value = nil
		else
			@value = DateTime.new @year.text.to_i, @month.text.to_i, @day.text.to_i
			@value
		end		
	end
end