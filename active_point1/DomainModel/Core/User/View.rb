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
	end
end