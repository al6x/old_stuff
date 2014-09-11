class EditPost < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		tab_js :active => `General`, :title => `Edit Post` do
			add `General`, :attributes do
				add `Title`, :string_edit, :attr => :title
				add `Details`, :text_edit, :attr => :details
				add nil, :richtext_edit, :attr => :content		
				add `Date`, :date_edit, :attr => :date
			end
			
			add `Extra`, :attributes do			
				add `URI`, :string_edit, :attr => :name				
				add `Icon`, :image_edit, :attr => :icon, :css => "icon"
			end						
		end
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end