class Setting < WComponent
	inherit UView
	
	attr_accessor :on_ok, :on_cancel
	
	build_view do |v|				
		form = v.new :box, :title => "Editing Blog", :style => "float border_left border_top"
		
		attrs = v.new :attributes		
		form.add attrs
		attrs.add "URI", v.new(:string_edit, :name => :entity_id)				
		attrs.add "Title", v.new(:string_edit, :name => :title)								
		
		sorting_order = v.new :select, :name => :sorting_order,
		:values => Blog::SORTING_ORDERS.keys
		attrs.add "Sorting Order", sorting_order						
		
		controls = v.new :flow, :style => "minimal"
		form.add controls
		controls.add v.new(:button, :text => "Ok", :action => [attrs, v.on_ok])
		controls.add v.new(:button, :text => "Cancel", :action => v.on_cancel)		
		
		v.root = form
	end
end