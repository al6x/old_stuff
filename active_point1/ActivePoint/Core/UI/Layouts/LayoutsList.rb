class LayoutsList < WComponent
	inherit UView
	
	build_view do |v|
		layouts = v.new :box, :style => "float border_left border_top input padding", :title => "Layouts"
		v.root = layouts
		
		# Controls
		controls = v.new :flow, :style => "minimal color2"		
		layouts.add controls		
		
		controls.add v.new(:button, :text => "Add", :action => :add_layout)
		unless v.object.layouts.empty?
			controls.add v.new(:button, :text => "Delete", :action => [layouts, :delete_layouts])
		end
		
		# Layouts
		layout_view = lambda do |u| 
			v.new :reference, :text => u.name, :value => u
		end
		list = v.new :table, :name => :layouts,
		:read_values => [:self], :head => ["Name"], :editors => [layout_view]
		layouts.add list
	end
end