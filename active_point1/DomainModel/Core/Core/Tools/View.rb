class View < DomainModel::Actions::View::Form
  build_view do |v|
    # Toolbar
    attributes_toolbar = v[:attributes_toolbar]			
    
    attributes_toolbar.add v.action(:on_edit)		
    
    # Attributes
    attributes = v[:attributes]		
    
    general = v.add :general, :attributes, :title => "General"
    attributes.add general
    
    # Tools
    tools_container = v.add :tools_container, :box, :padding => true    
    
    atools_reference_view = lambda do |value| 
      e = v.create :reference
      e.value = value
      e
    end    
    tools_table = v.add :tools, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [atools_reference_view]    
    
    edit_tools = v.action :edit_tools, :inputs => tools_table, 
		:selected => lambda{tools_table.selected}
		
		tools_container.add edit_tools
		tools_container.add tools_table		
    
    general.add :tools, tools_container
  end
end