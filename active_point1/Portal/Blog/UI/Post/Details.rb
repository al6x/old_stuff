class Details < WComponent	
	attr_accessor :object
	
	children :@title, :@details, :@icon
	
	def build
		@title = new :reference, :text => object.title, :value => object
		@details = new :string_view, :value => object.details
		@icon = new :image_view, :value => object.icon
	end		
end