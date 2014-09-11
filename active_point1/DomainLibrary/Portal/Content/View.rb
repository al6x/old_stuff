class View < DomainModel::Actions::View::Form
	include DomainModel::Core::Layouts::Layout::LayoutView
	build_view do |v|
		# Toolbar
		attributes_toolbar = v[:attributes_toolbar]			
		
		attributes_toolbar.add v.action(:on_edit)		
		
		# Attributes
		attributes = v[:attributes]		
		
		atext = v.add :text, :richtext_view
		attributes.add atext
		
		# Micelaneous
		micelaneous = v[:micelaneous]		
		
		general = v.add :general, :attributes
		micelaneous.add general
		
		
		# Items
    pages_container = v.add :pages_container, :box, :padding => true    
    
    apages_reference_view = lambda do |value| 
      e = v.create :reference
      e.value = value
      e
    end    
    pages_table = v.add :pages, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [apages_reference_view]            
    
    edit_pages = v.action :edit_pages, :inputs => pages_table, 
		:selected => lambda{pages_table.selected}
		
		pages_container.add edit_pages
		pages_container.add pages_table
    
    general.add :pages, pages_container
	end
end