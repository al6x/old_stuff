class GroupsList < WComponent
	inherit UView
	
	build_view do |v|
		groups = v.new :box, :style => "float border_left border_top input padding", :title => "Groups"
		v.root = groups
		
		# Controls
		controls = v.new :flow, :style => "minimal color2"		
		groups.add controls		
		
		controls.add v.new(:button, :text => "Add", :action => :add_group)
		unless v.object.groups.empty?
			controls.add v.new(:button, :text => "Delete", :action => [groups, :delete_groups])
		end
		
		# Groups
		group_view = lambda do |g| 
			v.new :reference, :text => g.name, :value => g
		end
		list = v.new :table, :name => :groups,
		:read_values => [:self], :head => ["Name"], :editors => [group_view]
		groups.add list
	end
end