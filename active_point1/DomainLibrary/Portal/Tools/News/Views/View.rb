class View < DomainModel::Actions::View::Form
	build_view do |v|
		# Toolbar
		attributes_toolbar = v[:attributes_toolbar]			
		
		attributes_toolbar.add v.action(:on_edit)		
		
		# Attributes
		attributes = v[:attributes]		
		
		general = v.add :general, :attributes
		attributes.add general
		
		# News
    news_container = v.add :news_container, :box, :padding => true    
    
    anews_reference_view = lambda do |value| 
      e = v.create :reference
      e.value = value
      e
    end    
    news_table = v.add :news, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [anews_reference_view]            
    
    edit_news = v.action :edit_news, :inputs => news_table, 
		:selected => lambda{news_table.selected}
		
		news_container.add edit_news
		news_container.add news_table
    
    general.add :news, news_container
	end
end