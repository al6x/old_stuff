class Tools
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "Tools"
    
    m.attribute :tools, :entity, "Tools", :container => :array    
    m.operation :edit_tools, :edit_child,  "Edit Tools", 
      :attribute => :tools, :custom => true
    
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name]    
    
    m.children :tools
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties
    
    m.action :edit_tools, :edit_child, :titles => ["Add", "Delete"], 
    :edit_action => :on_edit, :go_to => :parent, :skip_if_single => true
  end
end