class EditSite < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Edit Site`
		attributes do
			add `URI`,:string_edit, :attr => :name		
			add `Menu`,:string_edit, :attr => :menu 
			add `Logo`,:string_edit, :attr => :logo
			add `Slogan`,:string_edit, :attr => :description
			
			validate_html = lambda do |html|
				WComponent.validate_html html
				html			
			end
			add `Footer`,:string_edit, :attr => :footer, :before_write => validate_html
			
			# Menu
			#			list_to_text = lambda{|list| list.join("\n")}
			#			text_to_list = lambda do |text|
			#				menu = text.gsub("\r", "").split("\n")
			#				raise `Invalid Menu!` unless menu.all?{|path| R.include?(path)}
			#				menu
			#			end
			
			#			:before_read => list_to_text, :before_write => text_to_list				
		end
		
		line :wide => false do			
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end