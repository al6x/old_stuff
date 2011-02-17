class Config
	extend Configurator
	
	depends_on ::Portal::Core
	
	activate do
		Aspects::Model::Container::CONTENT_TYPES << Model::Site
		Aspects::Model::Container::CONTENT_TYPES << Model::SitePage
	end
	
	initialize_data do						
		R.transaction(Transaction.new){
			# SiteMenu
			appearance = R.by_id("Appearance")
			site_menu = C::Model::Wiget.new "Site Menu"
			site_menu.wiget_class = Site::Wigets::SiteMenu
			appearance.wigets << site_menu																								
		}.commit
	end		
end