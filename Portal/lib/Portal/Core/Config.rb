class Config
	extend Configurator
	
	activate do
		ct = Aspects::Model::Container::CONTENT_TYPES
		ct << Model::Page
		ct << Model::HTMLPage
	end
	
	initialize_data do	
		R.transaction(Transaction.new){
			# User Menu
			appearance = R.by_id("Appearance")		
			user_menu = appearance["User Menu"]
			
			# Breadcrumb
			breadcrumb = C::Model::Wiget.new "Breadcrumb"
			breadcrumb.wiget_class = WGUIExt::Wigets::Breadcrumb
			appearance.wigets << breadcrumb
			
			# Menu
			menu = C::Model::Wiget.new "Menu"
			menu.wiget_class = WGUIExt::Wigets::Menu
			appearance.wigets << menu
			
			# Logo
			logo = C::Model::Wiget.new "Logo"
			logo.wiget_class = WGUIExt::Wigets::Logo
			appearance.wigets << logo
			
			# Predefined Menu
			shortcuts = C::Model::Wiget.new "Shortcuts"
			shortcuts.wiget_class = Portal::Wigets::Shortcuts
			appearance.wigets << shortcuts												
			
			# Layout
			portal_layout = ActivePoint::Plugins::Appearance::Model::Layouts::BorderLayout.new "Portal Layout"				
			#				portal_layout.parameters = {
			#					:center => [
			#					{}, 
			#					{}, 
			#					{:css => "border_top border_left"}], 
			#					
			#					:left => [
			#					{}, 
			#					{:css => "border_top border_right"}, 
			#					{:css => "border_top border_right"}, 
			#					{:css => "border_top border_right"}]
			#				}
			portal_layout.center << breadcrumb
			portal_layout.center << R.by_id("Appearance")["Messages"]
			portal_layout.center << appearance["ObjectView"]
			portal_layout.left << logo
			portal_layout.left << menu
			portal_layout.left << shortcuts
			portal_layout.left << user_menu
			appearance.layouts << portal_layout
			
			# Portal				
			portal = R.by_id("Portal")
			portal.wc_layout = portal_layout
			portal.wc_skin = "Default"
			
			# Contact Us
			core = R.by_id "Core"
			contact_us = Core::Model::ContactUsList.new "Contact Us", "Contact Us"
			core.plugins << contact_us				
		}.commit
		
		# Files
		from = "#{File.dirname __FILE__}/../../../data/#{::ActivePoint::Adapters::Web::SKINS}"
		to = ActivePoint::CONFIG[:skins_directory]

		FileUtils.cp_r Dir.glob("#{from}/**"), to
	end
	
	clear_data do
		File.delete_directory ActivePoint::CONFIG[:skins_directory]
	end
end