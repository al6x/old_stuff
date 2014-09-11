class View < DomainModel::Actions::View::Form	
	build_view do |v|
		# Toolbar
		attributes_toolbar = v[:attributes_toolbar]			
		
		attributes_toolbar.add v.action(:on_edit)		
		
		# Attributes
		attributes = v[:attributes]		
		
		acontent = v.add :content, :string_view
		attributes.add acontent
		
		acontent2 = v.add :content2, :richtext_view
		attributes.add acontent2
	end
end