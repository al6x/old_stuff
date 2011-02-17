class EditPortal < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Edit Portal`
		richtext_edit :attr => :content
		
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end