class View < DomainModel::Actions::View::Form
	build_view do |v|
		# Toolbar
		attributes_toolbar = v[:attributes_toolbar]			
		
		attributes_toolbar.add v.action(:on_edit)		
		
		# Attributes
		attributes = v[:attributes]		
		
		general = v.add :general, :attributes
		attributes.add general
		
		alink = v.add :link, :reference
		general.add :link, alink
		
		adate = v.add :date, :date_view
		general.add :date, adate
		
		atext = v.add :text, :text_view
		general.add :text, atext
	end
end