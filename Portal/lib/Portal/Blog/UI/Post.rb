class Post
	inherit Controller
	editor EditPost
	
	def show
		@view = ShowPost.new.set :object => C.object		
	end
	
	def edit_post
		R.transaction_begin
		@view = EditPost.new
		@view.on[:ok] = lambda do						
			R.transaction{
				C.object.set @view.values
			}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
		@view.object = C.object		
	end
	
	def delete_post
		R.transaction_begin
		parent = C.object.parent
		R.transaction{C.object.delete}.commit
		C.object = parent
	end		
	
	def add_comment
		R.transaction_begin
		new_comment = nil
		R.transaction{new_comment = Model::Comment.new}
		@view = C.editor_for new_comment
		@view.on[:ok] = lambda do						
			R.transaction{
				new_comment.set @view.values				
				new_comment.author = C.user
				C.object.comments << new_comment				
			}.commit	
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	def edit_comment comment
		comment.should! :be_a, Model::Comment
		
		@view = C.editor_for comment
		@view.object = comment
		@view.on[:ok] = lambda do						
			R.transaction{
				R.by_id(comment.name).set @view.values
			}.commit	
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	def delete_comment comment
		comment.should! :be_a, Model::Comment
		
		R.transaction{
			R.by_id(comment.name).delete
		}.commit	
		show
	end
	
	secure :add_comment => :create,	:delete_post => :delete,
	:delete_comment => :delete, 
	:edit_post => lambda{(C.can?(:edit) and C.user == C.object.author) or C.can?(:manage)},
	:edit_comment => lambda{|comment|	(C.can?(:edit, comment) and C.user == comment.author) or C.can?(:manage, comment)}
end