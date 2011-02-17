class EditUser < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Edit User`
		attributes do
			add `Name`, :string_edit, :attr => :name
			add `Password`, :string_edit, :attr => :password
			add `Avatar`, :image_edit, :attr => :avatar, :css => "icon"
			add `Details`, :richtext_edit, :attr => :details
		end
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end