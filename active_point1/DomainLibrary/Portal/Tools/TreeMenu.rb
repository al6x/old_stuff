class TreeMenu
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "TreeMenu"
    
    m.attribute :menu, :entity, "TreeMenu"
        
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name]    
    
    m.children :menu
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => Views::View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => Views::EditProperties    
  end
  
  def build_tool object
  	WebClient::Wigets::Containers::Wrapper.new.set :component => 
		WebClient::Tools::TreeMenu
  end
end