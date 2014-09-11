class Reference < WLink
	include Editor	
	
	def initialize
		super
		self.style = "reference font"
	end
	
	def value= object
		return unless object
#		if @to_text
#			self.text = @to_text.call(object)
#		else
#			self.text = Utils::Extension.get_name(object) unless text
#		end		
		self.state = Utils::Extension.get_state(object)		
		refresh
	end	
	
#	def to_text= b
#		b.should! :be_a, Proc
#		@to_text = b
#		refresh
#	end
	
	def portlet
		Utils::Extension.get_portlet
	end
end