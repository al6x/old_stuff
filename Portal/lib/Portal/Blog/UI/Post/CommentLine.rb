class CommentLine < WComponent	
	attr_accessor :object
	children :@content, :@author, :@date, :@controls
	
	def build
		@content = new :richtext_view, :value => object.content
		@author = new :string_view, :value => object.author.name
		@date = new :date_view, :value => object.date		
		
		@controls = []
		@controls << new(:link_button, :text => `[Edit]`, :action => [:edit_comment, object])
		@controls << new(:link_button, :text => `[Delete]`, :action => [:delete_comment, object])
	end
end