class View < DomainModel::Actions::View::Form
	include DomainModel::Core::Layouts::Layout::LayoutView
	build_view do |v|
		# Toolbar
		attributes_toolbar = v[:attributes_toolbar]			
		
		attributes_toolbar.add v.action(:on_edit)								
		
		# Micelaneous
		micelaneous = v[:micelaneous]		
		
		micelaneous_attributes = v.add :micelaneous_attributes, :attributes
		micelaneous.add micelaneous_attributes
		
		acore = v.add :core, :reference
		micelaneous_attributes.add :core, acore
		
		attributes = v[:attributes]		
		
		general = v.add :general, :attributes
		attributes.add general
		
		asite = v.add :site, :reference
		general.add :site, asite
	end
end