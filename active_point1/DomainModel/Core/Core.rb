class Core
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "Core"
    
    m.attribute :users, :entity, "Users"  
        
    m.attribute :groups, :entity, "Groups" 
          
    m.attribute :layouts, :entity, "Layouts"    
          
    m.attribute :tools, :entity, "Tools"
    
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name]            
    
    m.children :users, :groups, :layouts, :tools
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => Views::View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => Views::EditProperties        
  end
end