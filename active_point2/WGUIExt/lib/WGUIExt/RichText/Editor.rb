class Editor < WComponent
	children :@editor, :@resources		
	
	def initialize data = RTData.new
		super()
		@data = data
	end
	
	def data= data
		@data = data
		refresh
	end		
	
	def on_add &block
		@on_add = block		
	end
	
	def on_delete &block
		@on_delete = block
	end
	
	def on_delete_get; @on_delete end
	def on_add_get; @on_add end
		
	def save
		@data.text = @editor.text
	end
	
	def build
		@editor = TinyMCE.new @data.text
		@resources = Resources.new self, @editor, @data.resources
		@editor.resources = @resources
	end
end