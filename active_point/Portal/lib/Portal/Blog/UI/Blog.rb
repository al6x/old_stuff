class Blog	
	inherit Controller
	inherit C::UI::Secure
	inherit C::UI::Layout
	inherit C::UI::Skinnable		
	
	editor EditBlog
	 
	def show
		@view = ShowBlog.new.set :object => C.object
	end	 
	
	def add_post
		R.transaction_begin
		new_post = nil
		R.transaction{new_post = Model::Post.new}
		@view = C.editor_for new_post
		@view.on[:ok] = lambda do						
			R.transaction{
				new_post.set @view.values
				new_post.name = new_post.title
				new_post.author = C.user
				C.object.posts << new_post				
			}.commit	
			show
		end
		@view.on[:cancel] = lambda{show}
		@view.object = new_post
	end
	
	def edit_blog
		R.transaction_begin
		@view = EditBlog.new		
		@view.on[:ok] = lambda do						
			R.transaction{
				C.object.set @view.values
			}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
		@view.object = C.object	
	end
	
	SORTING_ORDERS = {
		"Without Sorting" => nil,
		"By Date" => lambda{|a, b| a.date <=> b.date},
		"Latest" => lambda{|a, b| b.date <=> a.date},
	}		
	
	secure \
	:add_post => :create,
	:edit_blog => :manage
end