class View < DomainModel::Actions::View::Form
  build_view do |v|
    # Toolbar
    attributes_toolbar = v[:attributes_toolbar]			
    
    attributes_toolbar.add v.action(:on_edit)		
    
    # Attributes
    attributes = v[:attributes]		
    
    general = v.add :general, :attributes, :title => "General"
    attributes.add general
    
    # Groups
    groups_container = v.add :groups_container, :box, :padding => true    
    
    agroups_reference_view = lambda do |value| 
      e = v.create :reference
      e.value = value
      e
    end    
    groups_table = v.add :groups, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [agroups_reference_view]            
    
    edit_groups = v.action :edit_groups, :inputs => groups_table, 
		:selected => lambda{groups_table.selected}
		
		groups_container.add edit_groups
		groups_container.add groups_table
    
    general.add :groups, groups_container
  end
end