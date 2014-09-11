class View < WComponent
	inherit UView
	
	build_view do |v|
		form = v.new :box, :style => "float border_left border_top input padding", :title => "Tool Definition"
		v.root = form
		
		attrs = v.new :attributes
		form.add attrs		
		attrs.add "Name", v.new(:string_view, :name => :name)
		attrs.add "Class", v.new(:string_view, :name => :tool_class, :before_read => lambda{|c| c.to_s})
		attrs.add "Parameters", v.new(:text_view, :name => :parameters_source)
		
		controls = v.new :flow, :style => "minimal input padding"
		form.add controls		
		controls.add v.new(:button, :text => "Edit", :action => :edit_tool)
	end
end