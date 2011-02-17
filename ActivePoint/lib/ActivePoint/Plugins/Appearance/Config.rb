class Config
	extend Configurator
	
	depends_on Core
	
	startup do
		if R.include_id? "Appearance"
			appearance = R.by_id "Appearance"
			appearance.wigets.each do |wiget|
				wiget.register_wiget unless Scope.include? wiget.name
			end
		end
	end
	
	initialize_data do 
		R.transaction(Transaction.new){
			core = R.by_id "Core"
			ap = Model::Appearance.new "Appearance", "Appearance"
			core.plugins << ap
			
			ap.wigets << Model::ObjectViewWiget.new("ObjectView", "ObjectView")
			ap.wigets << Model::Wiget.new("Messages").set!(:wiget_class => Adapters::Web::Wigets::Messages)
			ap.wigets << Model::Wiget.new("User Menu").set!(:wiget_class => Adapters::Web::Wigets::UserMenu)
		}.commit
	end	
end