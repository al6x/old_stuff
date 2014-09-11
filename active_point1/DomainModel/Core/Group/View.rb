class View < DomainModel::Actions::View::Form
  build_view do |v|
    # Toolbar
    attributes_toolbar = v[:attributes_toolbar]			
    
    attributes_toolbar.add v.action(:on_edit)		
    
    # Attributes
    attributes = v[:attributes]		
    
    general = v.add :general, :attributes, :title => "General"
    attributes.add general
    
    # Included    
    entity_reference_view = lambda do |value| 
      e = v.create :reference
      e.value = value
      e
    end    
    included_in_table = v.add :included_in, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [entity_reference_view], :selector => false      
    
    general.add :included_in, included_in_table

    # Groups
		groups_container = v.add :groups_container, :box, :padding => true    
    
    groups_table = v.add :groups, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [entity_reference_view]            
    
    edit_groups = v.action :edit_groups, :inputs => groups_table, 
		:selected => lambda{groups_table.selected}
		
		groups_container.add edit_groups
		groups_container.add groups_table
    
    general.add :groups, groups_container
    
    # Users
    users_container = v.add :users_container, :box, :padding => true    
        
    users_table = v.add :users, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [entity_reference_view]            
    
    edit_users = v.action :edit_users, :inputs => users_table, 
		:selected => lambda{users_table.selected}
		
		users_container.add edit_users
		users_container.add users_table
    
    general.add :users, users_container
  end
end