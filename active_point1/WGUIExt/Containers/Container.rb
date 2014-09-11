module Container
	include  Log
	
	attr_accessor :name
	
	def name= value
		@name = value
		self.component_id = "#{value}_#{component_id}"
	end			
end