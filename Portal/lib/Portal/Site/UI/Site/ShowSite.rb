class ShowSite < WComponent
	inherit Form
		
	build :tab, :component_id => "tab_site" do
		set! :active => `Container`, :title => `Site`
		add `Container`, :box, :css => "padding" do
			add Aspects::UI::Container::ShowContainer.new(form).set!(:object => object)
		end
		
		add `Properties`, :box, :css => "padding" do
			attributes do
				add `URI`, :string_view, :attr => :name
				add `Menu`, :string_view, :attr => :menu
				add `Logo`, :string_view, :attr => :logo
				add `Slogan`, :string_view, :attr => :description
				add `Footer`, :string_view, :attr => :footer, :no_escape => true				
			end
			button :text => `Edit`, :action => :edit
			
			add C::UI::ShowSecure.new.set!(:object => object)	
			add C::UI::ShowLayout.new.set!(:object => object)			
			add C::UI::ShowSkinnable.new.set!(:object => object)
		end
	end
end