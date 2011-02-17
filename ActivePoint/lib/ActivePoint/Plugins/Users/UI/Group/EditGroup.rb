class EditGroup < WComponent
	inherit Form	
	
	build :box, :css => "padding" do
		set! :title => `Edit Group`
		
		attributes do
			add `Name`, :string_edit, :attr => :name
		end
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end