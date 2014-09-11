class ObjectLink < WLink
	include Editor	
	
	def initialize
		super
		self.css = "reference font" 
	end
	
	def value= object
		@object = object
		return unless object
#		if @to_text
#			self.text = @to_text.call(object)
#		else
#			self.text = Utils::Extension.get_name(object) unless text
#		end		
		self.text = Utils::Extension.get_name(object) unless text and !text.empty?
		self.state = Utils::Extension.get_path(object)		
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