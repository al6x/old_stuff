class ShowPortal < WComponent
	inherit Form
	
	build :tab, :component_id => "portal_tab" do		
		set! :title => object.name, :active => `Content`
		
		add `Content`, :box, :css => "padding" do
			richtext_view :attr => :content
			link_button :text => `[Edit]`, :action => :edit
		end
		
		add `Container`, :box, :css => "padding" do
			add Aspects::UI::Container::ShowContainer.new(form).set(:object => object)
		end
		
		add `Properties`, :box, :css => "padding" do
			attributes do
				add `Name`, :string_view, :attr => :name
				add `Core`, :link, :text => `Core`, :attr => :core
			end
			add C::UI::ShowSecure.new.set(:object => object)
			add C::UI::ShowLayout.new.set(:object => object)
			add C::UI::ShowSkinnable.new.set(:object => object)
			button :text => `Edit`, :action => :edit
		end
	end
end