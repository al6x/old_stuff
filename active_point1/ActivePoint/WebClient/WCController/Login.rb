class Login < WComponent
	inherit UView
	
	attr_reader :on_ok, :on_cancel
	
	metadata do |v|
		form = v.new :box, :title => "Login"		
		v.root = form
		
		attrs = v.new :attributes
		form.add attrs
		
		attrs.add "Name", v.new(:string_edit, :name => :name)
		attrs.add "Password", v.new(:string_edit, :name => :name, :password => true)
		
		controls = v.new :flow
		form.add controls
		
		controls.add v.new(:button, "Ok", :action => [form, v.on_ok])
		controls.add v.new(:button, "Cancel", :action => v.on_cancel)
	end
end