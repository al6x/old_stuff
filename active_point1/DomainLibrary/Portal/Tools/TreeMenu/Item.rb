class Item
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "Item"
    
    m.attribute :link, :entity, "Link"
    
    m.attribute :items, :entity, "Items", :container => :array    
    m.operation :edit_items, :edit_child,  "Edit Items", 
      :attribute => :items, :select => lambda{|current| [Item]}
        
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name, :link]    
    
    m.children :items
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties
    
    m.action :edit_items, :edit_child, :titles => ["Add", "Delete"], 
    :edit_action => :on_edit, :go_to => :child, :skip_if_single => true
  end
  
  def build_tool object
  	NewsTool.new :news => news
  end
end