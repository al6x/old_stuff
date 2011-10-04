class EditPage < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Edit Page`
		attributes do
			add `Name`, :string_edit, :attr => :name
			add `Menu`, :string_edit, :attr => :menu
		end
		richtext_edit :attr => :content
		
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end