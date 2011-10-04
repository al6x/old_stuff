class Group	
	inherit Controller
	editor EditGroup	
	
	def show
		@view = ShowGroup.new.set :object => C.object
	end
	
	def edit_group
		R.transaction_begin
		@view = EditGroup.new.set :object => C.object
		@view.on[:ok] = lambda do						
			R.transaction{
				o = C.object
				o.set @view.values
			}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	def add_user
		R.transaction_begin		
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values]
		end
		@view.on[:ok] = lambda do						
			user_name = @view[:value].value
			raise `User not selected!` if user_name.empty?
			user = R.by_id("Users")[user_name]
			R.transaction{
				o = C.object
				o.users << user
				user.included_in << o
			}.commit
			show
		end
		@view.on[:cancel] = lambda{show}		
		values = (R.by_id("Core")["Users"].users.to_set - C.object.users.to_set).collect{|u| u.name}
		@view.object = {:title => `Add User`, :value => "", :values => values}				
	end
	
	def delete_user
		R.transaction_begin
		R.transaction{
			@view[:users].selected.each do |u|
				C.object.users.delete u
			end
		}.commit
		show
	end
	
	def add_group
		R.transaction_begin
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values]
		end
		@view.on[:ok] = lambda do						
			group_name = @view[:value].value
			raise `Group not selected!` if group_name.empty?
			group = R.by_id("Users")[group_name]
			R.transaction{
				o = C.object
				o.groups << group				
				group.included_in << o
			}.commit
			show
		end
		@view.on[:cancel] = lambda{show}		
		groups_to_select = (R.by_id("Core")["Users"].groups.to_set - C.object.groups.to_set)
		groups_to_select.delete C.object
		@view.object = {:title => `Add Group`, :value => "", :values => groups_to_select.collect{|g| g.name}}
	end
	
	def delete_group
		R.transaction_begin
		R.transaction{
			@view[:groups].selected.each do |g|
				o = C.object
				o.groups.delete g
				g.included_in.delete o
			end
		}.commit
		show
	end
		
end