class ShowPost < WComponent
	attr_accessor :object
	
	children :@author, :@content, :@date, :@controls, :@comments, :@icon
	
	def build
		@title = object.title
		@author = new :string_view, :value => object.author.name
		@icon = new :image_view, :value => object.icon
		@content = new :richtext_view, :value => object.content	
		@date = new :date_view, :value => object.date	
		
		@controls = []
		@controls <<  new(:link_button, :text => `[Comment]`, :action => :add_comment)
		@controls <<  new(:link_button, :text => `[Edit]`, :action => :edit_post)
		@controls <<  new(:link_button, :text => `[Delete]`, :action => :delete_post)
		
		list = object.comments.sort{|a, b| a.date <=> b.date}
		@comments = list.collect{|o| CommentLine.new.set :object => o}
	end
	
	#	def build
	#		super
	#		Scope.add_observer object.name, self, :refresh
	#	end
end