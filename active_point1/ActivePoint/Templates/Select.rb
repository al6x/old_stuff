class Select < WComponent
	inherit UView
	
	attr_accessor :title, :parameters
	
	attr_accessor :on_cancel, :on_ok
	
	build_view do |v|
		form = v.new :box, :title => v.title.should_not!(:be_nil)
		v.root = form
		
		select = v.new(:select, :name => :select)
		select.set v.parameters if v.parameters
		form.add select		
		
		controls = v.new :flow, :style => "minimal input padding"
		form.add controls		
		controls.add v.new(:button, :text => "Ok", :action => [form, v.on_ok])		
		controls.add v.new(:button, :text => "Cancel", :action => v.on_cancel)
	end		
end