class Edit < WComponent
	inherit UView
	
	attr_accessor :on_ok, :on_cancel
	
	build_view do |v|
		form = v.new :box, :style => "float border_left border_top input padding", :title => "Edit Layout"
		v.root = form
		
		attrs = v.new :attributes
		form.add attrs		
		attrs.add "Name", v.new(:string_edit, :name => :name)
		
		controls = v.new :flow, :style => "minimal input padding"
		form.add controls		
		controls.add v.new(:button, :text => "Ok", :action => [form, v.on_ok])
		controls.add v.new(:button, :text => "Cancel", :action => v.on_cancel)
	end
end