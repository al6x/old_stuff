class Post
	inherit Controller
	
	def initialize
		@view = View.new
		@view.object = C.object		
	end
	
	def edit_post
		C.transaction_begin
		form = Post::Edit.new
		form.on_ok = lambda do						
			R.transaction{
				C.object.set form.values
			}.commit
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = C.object		
		@view.subflow form
	end
	
	def delete_post
		C.transaction_begin
		parent = C.object.parent
		R.transaction{C.object.delete}.commit
		C.object = parent
	end		
end