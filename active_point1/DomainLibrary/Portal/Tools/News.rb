class News
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "News"
    
    m.attribute :news, :entity, "News", :container => :array    
    m.operation :edit_news, :edit_child,  "Edit News", 
      :attribute => :news, :select => lambda{|current| [Item]}
        
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name]    
    
    m.children :news
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => Views::View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => Views::EditProperties
    
    m.action :edit_news, :edit_child, :titles => ["Add", "Delete"], 
    :edit_action => :on_edit, :go_to => :child, :skip_if_single => true
  end
  
  def build_tool object
  	NewsTool.new :news => news
  end
end