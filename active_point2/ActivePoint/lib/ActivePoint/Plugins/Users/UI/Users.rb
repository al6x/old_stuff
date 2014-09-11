class Users
	inherit Controller
	
	def show
		@view = ShowUsers.new
		@view.object = C.object
	end
	
	def add_user
		R.transaction_begin
		new_user = nil
		R.transaction{new_user = Model::User.new}
		@view = C.editor_for new_user
		@view.object = new_user
		@view.on[:ok] = lambda do					
			R.transaction{
				new_user.set @view.values				
				new_user.validate
				raise `Not Unique Name!` if C.object.users.any?{|u| u.name == new_user.name}
				
				C.object.users << new_user
			}.commit	
			show
		end
		@view.on[:cancel] = lambda{show}		
	end
	
	def delete_users
		R.transaction_begin
		R.transaction{
			@view[:users].selected.every.delete #each{|entity_id| R.by_id(entity_id).delete}
		}.commit
		show
	end
	
	def add_group
		R.transaction_begin
		new_group = nil		
		R.transaction{new_group = Model::Group.new}
		@view = C.editor_for new_group
		@view.object = new_group
		@view.on[:ok] = lambda do					
			R.transaction{
				new_group.set @view.values				
				new_group.validate				
				raise `Not Unique Name!` if C.object.groups.any?{|g| g.name == new_group.name}
				
				C.object.groups << new_group
			}.commit	
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	def delete_groups
		R.transaction_begin
		R.transaction{
			@view[:groups].selected.every.delete #each{|entity_id| R.by_id(entity_id).delete}
		}.commit
		show
	end
end