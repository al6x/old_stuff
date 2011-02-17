class EditSitePage < WComponent
	inherit Form
	
	build :box do
		tab_js :active => `Properties`, :title => `Edit Page` do
			add `Properties`, :attributes do
				add `URI`, :string_edit, :attr => :name
				add `Menu`, :string_edit, :attr => :menu
				add `Title`, :string_edit, :attr => :title
				add nil, :richtext_edit, :attr => :content	
			end
			
			add `Container`, :box, :css => "padding" do
				add Aspects::UI::Container::ShowContainer.new(form).set!(:object => object)
			end
			
			add `Extra`, :box, :css => "padding" do
#				box :css => "padding", :title => `Sidebar` do
#					validate_html = lambda do |html|
#						WGUI::Utils::TemplateHelper.validate html rescue raise `Invalid HTML for Sidebar!`
#						html			
#					end
#					text_edit :attr => :sidebar, :before_write => validate_html
#				end
				
				add C::UI::ShowSecure.new.set!(:object => object)
				add C::UI::ShowLayout.new.set!(:object => object)
			end
		end
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end