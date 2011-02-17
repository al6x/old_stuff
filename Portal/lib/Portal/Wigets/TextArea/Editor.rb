class Editor < WComponent
	inherit Form
	
	build :box do
		set! :title => `Edit Banner`
		attributes do
			add `Title`, :string_edit, :attr => :title
		end
		richtext_edit :attr => :content
		
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end