class ShowBlog < WComponent
	children :@title, :@add, :@edit, :@posts
	
	attr_accessor :object
	
	def build
		@title = new :string_view, :value => object.title
		@add = new :link_button, :text => `[New Post]`, :action => :add_post
		@edit = new :link_button, :text => `[Edit]`, :action => :edit_blog
		list = object.posts.sort &SORTING_ORDERS[object.sorting_order]
		@posts = list.collect do |post|
			PostLine.new.set :object => post
		end
	end	
end