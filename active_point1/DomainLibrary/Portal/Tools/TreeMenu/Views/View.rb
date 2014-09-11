class View < DomainModel::Actions::View::Form
	build_view do |v|
		# Toolbar
		attributes_toolbar = v[:attributes_toolbar]			
		
		attributes_toolbar.add v.action(:on_edit)		
		
		# Attributes
		attributes = v[:attributes]		
		
		general = v.add :general, :attributes
		attributes.add general
		
		amenu = v.add :menu, :reference
    general.add :menu, amenu
	end
end