class Group	
	inherit Controller
	
	def initialize
		@view = View.new
		@view.object = C.object
	end
	
	def edit_group
		C.transaction_begin
		form = Edit.new
		form.on_ok = lambda do						
			R.transaction{
				o = C.object
				o.set form.values
			}.commit
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = C.object		
		@view.subflow form
	end
	
	def add_user
		C.transaction_begin
		form = WebClient::Templates::Select.new
		form.title = "Add User"
		form.on_ok = lambda do						
			user_name = form[:select].value
			raise "User not selected!" if user_name.empty?
			user = R["Core/Users"][user_name]
			R.transaction{
				o = C.object
				o.users << user
				user.included_in << o
			}.commit
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}		
		form.parameters = {:values => (R["Core/Users"].users.to_set - C.object.users.to_set).collect{|u| u.name}}
		form.object = {:select => ""}
		@view.subflow form
	end
	
	def delete_user
		C.transaction_begin
		R.transaction{
			@view[:users].selected.each do |u|
				C.object.users.delete u
			end
		}.commit
		@view.object = C.object
		@view.refresh
	end
	
	def add_group
		C.transaction_begin
		form = WebClient::Templates::Select.new
		form.title = "Add Group"
		form.on_ok = lambda do						
			group_name = form[:select].value
			raise "Group not selected!" if group_name.empty?
			group = R["Core/Groups"][group_name]
			R.transaction{
				o = C.object
				o.groups << group				
				group.included_in << o
			}.commit
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}		
		groups_to_select = (R["Core/Groups"].groups.to_set - C.object.groups.to_set)
		groups_to_select.delete C.object
		form.parameters = {:values => groups_to_select.collect{|g| g.name}}
		form.object = {:select => ""}
		@view.subflow form
	end
	
	def delete_group
		C.transaction_begin
		R.transaction{
			@view[:groups].selected.each do |g|
				o = C.object
				o.groups.delete g
				g.included_in.delete o
			end
		}.commit
		@view.object = C.object
		@view.refresh
	end
end