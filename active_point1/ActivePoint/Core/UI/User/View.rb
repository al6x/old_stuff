class View < WComponent
	inherit UView
	
	build_view do |v|
		form = v.new :box, :style => "float border_left border_top input padding", :title => "User"
		v.root = form
		
		attrs = v.new :attributes
		form.add attrs		
		attrs.add "Name", v.new(:string_view, :name => :name)
		attrs.add "Avatar", v.new(:image_view, :name => :avatar, :style => "icon")
		attrs.add "Details", v.new(:richtext_view, :name => :details)	
		
		group_view = lambda do |g| 
			v.new :reference, :text => g.name, :value => g
		end
		list = v.new :table, :name => :included_in, :selector => false,
		:read_values => [:self], :head => ["Name"], :editors => [group_view]			
		attrs.add "Included In", list
		
		controls = v.new :flow, :style => "minimal input padding"
		form.add controls		
		controls.add v.new(:button, :text => "Edit", :action => :edit_user)
		controls.add v.new(:button, :text => "Delete", :action => :delete_user)
	end
end