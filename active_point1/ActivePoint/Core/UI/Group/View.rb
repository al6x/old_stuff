class View < WComponent
	inherit UView
	
	build_view do |v|
		form = v.new :box, :style => "float border_left border_top"
		v.root = form
		
		tab = v.new :tab, :component_id => "group_tab", :active => "Users", :title => v.object.name
		form.add tab
		
		tab.add "Users", build_users(v)
		tab.add "Groups", build_groups(v)
		tab.add "Details", build_details(v)
		
		controls = v.new :flow, :style => "minimal input padding"
		form.add controls		
		controls.add v.new(:button, :text => "Edit", :action => :edit_group)
		controls.add v.new(:button, :text => "Delete", :action => :delete_group)
	end
	
	class << self
		def build_users v
			form = v.new :box
			
			controls = v.new :flow, :style => "minimal input padding color2"
			form.add controls
			controls.add v.new(:button, :text => "Add", :action => :add_user)		
			unless v.object.users.empty?
				controls.add v.new(:button, :text => "Delete", :action => [form, :delete_user])		
			end
			
			user_view = lambda do |u| 
				v.new :reference, :text => u.name, :value => u
			end
			list = v.new :table, :name => :users,
			:read_values => [:self], :head => ["Name"], :editors => [user_view]			
			form.add list
			
			return form
		end
		
		def build_groups v
			form = v.new :box
			
			controls = v.new :flow, :style => "minimal input padding color2"
			form.add controls
			controls.add v.new(:button, :text => "Add", :action => :add_group)		
			unless v.object.groups.empty?
				controls.add v.new(:button, :text => "Delete", :action => [form, :delete_group])		
			end
			
			group_view = lambda do |g| 
				v.new :reference, :text => g.name, :value => g
			end
			list = v.new :table, :name => :groups,
			:read_values => [:self], :head => ["Name"], :editors => [group_view]			
			form.add list
			
			return form
		end
		
		def build_details v
			form = v.new :attributes, :style => "float input padding"						
			
			group_view = lambda do |g| 
				v.new :reference, :text => g.name, :value => g
			end
			list = v.new :table, :name => :included_in, :selector => false,
			:read_values => [:self], :head => ["Name"], :editors => [group_view]			
			form.add "Included In", list
			
			return form
		end
	end
end