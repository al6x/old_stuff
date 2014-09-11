class PostLine < WComponent	
	attr_accessor :object
	
	children :@title, :@details, :@icon, :@author, :@date
	
	def build
		@title = new :link, :text => object.title, :value => object
		@details = new :string_view, :value => object.details, :no_escape => true
		@icon = new :image_view, :value => object.icon
		@author = new :string_view, :value => object.author.name
		@date = new :date_view, :value => object.date
	end		
end