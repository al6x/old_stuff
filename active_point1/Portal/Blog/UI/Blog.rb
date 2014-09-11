class Blog	
	inherit Controller
	inherit ActivePoint::Core::UI::Secure
	inherit ActivePoint::Core::UI::Layout
	inherit ActivePoint::Core::UI::Skinnable		
	 
	def initialize
		@view = View.new
		@view.object = C.object
	end	 
	
	def add_post
		C.transaction_begin
		new_post = nil
		R.transaction{new_post = Model::Post.new}
		form = Post::Edit.new
		form.on_ok = lambda do						
			R.transaction{
				new_post.set form.values
				new_post.entity_id = new_post.title
				C.object.posts << new_post				
			}.commit	
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = new_post
		@view.subflow form
	end
	
	def edit_setting
		C.transaction_begin
		form = Setting.new		
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
	
	SORTING_ORDERS = {
		"Without Sorting" => nil,
		"By Date" => lambda{|a, b| a.date <=> b.date},
		"Latest" => lambda{|a, b| b.date <=> a.date},
	}		
	
	secure \
	:add_post => ["Edit"],
	:edit_setting => "Edit"
end