class Button < Core::Wiget	
	include Core::ExecutableWiget
	attr_reader :text
	
	def initialize text = "", inputs = [], &action
		super()
		on "click", inputs, &action    
		@text = text
	end			
		
	def text= text		
		return if @text == text
		@text = text
		refresh
	end
	
	def action inputs = [], &action
		on "click", inputs, &action    
	end
	
	def action= params
		if params.is_a? Array
			params.size.should! :==, 2
			inputs, action = params[0], params[1].should!(:be_a, Proc)
			on "click", inputs, &action
		elsif params.is_a? Proc
			action = params.should!(:be_a, Proc)
			on "click", [], &action
		else
			should! :be_never_called
		end				
	end
end