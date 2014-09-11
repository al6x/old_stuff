class View < WComponent
	children :@resources		
	
	def initialize data = RTData.new
		super()
		@data = data
	end
	
	def data= data
		@data = data
		refresh
	end	
	
	def on_delete_get; nil end
	def on_add_get; nil end
	
	def build
		@resources = Resources.new self, nil, @data.resources
	end
end