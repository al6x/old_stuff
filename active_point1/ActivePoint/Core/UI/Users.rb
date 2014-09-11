class Users
	inherit Controller
	
	def initialize
		@view = UsersList.new
		@view.object = C.object
	end
	
	def add_user
		C.transaction_begin
		new_user = nil
		R.transaction{new_user = Model::User.new}
		form = User::Edit.new
		form.on_ok = lambda do					
			R.transaction{
				new_user.set form.values				
				new_user.validate
				raise "Not Unique Name!" if C.object.users.any?{|u| u.name == new_user.name}
				
				C.object.users << new_user
			}.commit	
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = new_user
		@view.subflow form
	end
	
	def delete_users
		C.transaction_begin
		R.transaction{
			@view[:users].selected.every.delete #each{|om_id| R.by_id(om_id).delete}
		}.commit
		@view.object = C.object
		@view.refresh
	end
end