class User	
	inherit Controller
	editor EditUser	
	
	def show
		@view = ShowUser.new.set :object => C.object
	end
	
	def edit_user
		R.transaction_begin
		@view = EditUser.new.set :object => C.object
		@view.on[:ok] = lambda do						
			R.transaction{C.object.set @view.values}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	def delete_user
		R.transaction_begin
		parent = C.object.parent
		R.transaction{C.object.delete}.commit
		C.object = parent
	end				
end