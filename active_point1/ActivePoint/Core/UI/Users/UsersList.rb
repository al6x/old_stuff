class UsersList < WComponent
	inherit UView
	
	build_view do |v|
		users = v.new :box, :style => "float border_left border_top input padding", :title => "Users"
		v.root = users
		
		# Controls
		controls = v.new :flow, :style => "minimal color2"		
		users.add controls		
		
		controls.add v.new(:button, :text => "Add", :action => :add_user)
		unless v.object.users.empty?
			controls.add v.new(:button, :text => "Delete", :action => [users, :delete_users])
		end
		
		# Users
		user_view = lambda do |u| 
			v.new :reference, :text => u.name, :value => u
		end
		list = v.new :table, :name => :users,
		:read_values => [:self], :head => ["Name"], :editors => [user_view]
		users.add list
	end
end