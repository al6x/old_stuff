class ResultSet < Array
	
	[:type, :select, :eval].each{|m| undef_method m}
	
	attr_reader :browser		
	
	def initialize browser
		super()
		@browser = browser
	end
	
	def filter name, *args
		@browser.filter name, self, *args
	end		
	
	def inverse_filter name, *args
		@browser.inverse_filter name, self, *args
	end
	
	def text= value
		method_missing :type, value
	end
	
	def method_missing m, *args, &b
		if size > 1
			raise "More than one Element!"
		elsif size == 0
			raise "No Elments!"
		end
		
		m = :"xpath_#{m}"
		if @browser.respond_to? m
			@browser.send m, self.first.xpath, *args, &b
		else
			super
		end
	end
end