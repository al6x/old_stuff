class View < DomainModel::Actions::View::Form
  build_view do |v|
    # Toolbar
    attributes_toolbar = v[:attributes_toolbar]			
    
    attributes_toolbar.add v.action(:on_edit)		
    
    # Attributes
    attributes = v[:attributes]		
    
    general = v.add :general, :attributes, :title => "General"
    attributes.add general
    
    # Users
    users_container = v.add :users_container, :box, :padding => true    
    
    ausers_reference_view = lambda do |value| 
      e = v.create :reference
      e.value = value
      e
    end    
    users_table = v.add :users, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [ausers_reference_view]    
    
    edit_users = v.action :edit_users, :inputs => users_table, 
		:selected => lambda{users_table.selected}
		
		users_container.add edit_users
		users_container.add users_table		
    
    general.add :users, users_container
  end
end