class Content	
  inherit OGDomain::Entity
  include DomainModel::Core::Layouts::Layout
  
  build_dmeta do |m|
    m.entity_name "Content"    
    
    m.attribute :text, :richtext, "Text"
    
    m.attribute :pages, :entity, "Pages", :container => :array    
    m.operation :edit_pages, :edit_child,  "Edit Pages", 
      :attribute => :pages, :select => lambda{|current| [Content]}
        
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name, :text]    
    
    m.children :pages
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties
    
    m.action :edit_pages, :edit_child, :titles => ["Add", "Delete"], 
    :edit_action => :on_edit, :go_to => :child, :skip_if_single => true
  end
end