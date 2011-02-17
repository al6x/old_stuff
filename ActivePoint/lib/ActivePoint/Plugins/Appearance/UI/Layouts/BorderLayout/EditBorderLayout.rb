class EditBorderLayout < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Edit Layout`
		attributes do
			add `Name`, :string_edit, :attr => :name
		end
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
	
#	build_view do |v|
#		form = v.new :box, :style => "float border_left border_top input padding", :title => "Edit Layout"
#		v.root = form
#		
#		attrs = v.new :attributes
#		form.add attrs		
#		attrs.add "Name", v.new(:string_edit, :name => :name)
#		
#		controls = v.new :flow, :style => "minimal input padding"
#		form.add controls		
#		controls.add v.new(:button, :text => "Ok", :action => [form, v.on[:ok]])
#		controls.add v.new(:button, :text => "Cancel", :action => v.on[:cancel])
#	end
end