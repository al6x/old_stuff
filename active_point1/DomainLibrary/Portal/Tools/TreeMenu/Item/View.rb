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
		
		# Items
    items_container = v.add :items_container, :box, :padding => true    
    
    aitems_reference_view = lambda do |value| 
      e = v.create :reference
      e.value = value
      e
    end    
    items_table = v.add :items, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [aitems_reference_view]            
    
    edit_items = v.action :edit_items, :inputs => items_table, 
		:selected => lambda{items_table.selected}
		
		items_container.add edit_items
		items_container.add items_table
    
    general.add :items, items_container
	end
end