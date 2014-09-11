class View < DomainModel::Actions::View::Form
	build_view do |v|
		# Toolbar
		attributes_toolbar = v[:attributes_toolbar]			
		
		attributes_toolbar.add v.action(:on_edit)
		
		# Attributes
		attributes = v[:attributes]		
		
		general = v.add :general, :attributes, :title => "General"
		attributes.add general
		
		ausers = v.add :users, :reference
		general.add nil, ausers
		
		agroups = v.add :groups, :reference
		general.add nil, agroups
		
		alayouts = v.add :layouts, :reference
		general.add nil, alayouts						
		
		atools = v.add :tools, :reference
		general.add nil, atools
	end
end