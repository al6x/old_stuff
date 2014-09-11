class ParentContinuation
	attr_accessor :result
	def initialize wiget; 
		@wiget, @result, @found = wiget, nil, false
    end
	
	def accept wiget
		return if @found
		
		if wiget.is_a? WContinuation
			@result = wiget
		elsif wiget == @wiget
			@found = true
        end
    end
	
	def visit_children?; !@found end
end