class EditBlog < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Edit Blog`
		attributes do
			add `URI`, :string_edit, :attr => :name
			add `Menu`, :string_edit, :attr => :menu
			add `Title`, :string_edit, :attr => :title
			add `Sorting Order`, :select, :attr => :sorting_order, 
			:values => Blog::SORTING_ORDERS.keys
		end
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]		
		end
		
		add C::UI::ShowSecure.new.set! :object => object
		add C::UI::ShowLayout.new.set! :object => object
		add C::UI::ShowSkinnable.new.set! :object => object
	end	
end