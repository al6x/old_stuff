class ContactUsForm < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Contact Us`
		attributes do
			add `Title`, :string_edit, :attr => :title
			add `Name`, :string_edit, :attr => :name
			add `e-Mail`, :string_edit, :attr => :email
			add `Message`, :text_edit, :attr => :message
		end
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end	
end