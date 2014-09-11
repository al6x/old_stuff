class EditHTMLPage < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Edit HTMLPage`
		attributes do
			add `URI`, :string_edit, :attr => :name			
			add `Menu`, :string_edit, :attr => :menu
		end
		validate_html = lambda do |html|
			WComponent.validate_html html
			html			
		end
		text_edit :attr => :html, :before_write => validate_html
		
		add C::UI::ShowSecure.new.set!(:object => object)
		add C::UI::ShowLayout.new.set!(:object => object)
		
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end