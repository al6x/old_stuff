class Item
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "Item"
    
    m.attribute :link, :entity, "Link"
    
    m.attribute :text, :string, "Text"    
    
    m.attribute :date, :date, "Date"
        
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name, :link, :text, :date]    
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties
  end
end