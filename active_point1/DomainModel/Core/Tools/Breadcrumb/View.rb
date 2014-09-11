class View < DomainModel::Actions::View::Form
	build_view do |v|
		# Toolbar
		attributes_toolbar = v[:attributes_toolbar]			
		
		attributes_toolbar.add v.action(:on_edit)	
	end		
end