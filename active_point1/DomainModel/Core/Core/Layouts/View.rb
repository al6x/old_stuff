class View < DomainModel::Actions::View::Form
  build_view do |v|
    # Toolbar
    attributes_toolbar = v[:attributes_toolbar]			
    
    attributes_toolbar.add v.action(:on_edit)		
    
    # Attributes
    attributes = v[:attributes]		
    
    general = v.add :general, :attributes, :title => "General"
    attributes.add general
    
    # layouts
    layouts_container = v.add :layouts_container, :box, :padding => true    
    
    alayouts_reference_view = lambda do |value| 
      e = v.create :reference
      e.value = value
      e
    end    
    layouts_table = v.add :layouts, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [alayouts_reference_view]    
    
    edit_layouts = v.action :edit_layouts, :inputs => layouts_table, 
		:selected => lambda{layouts_table.selected}
		
		layouts_container.add edit_layouts
		layouts_container.add layouts_table		
    
    general.add :layouts, layouts_container
  end
end