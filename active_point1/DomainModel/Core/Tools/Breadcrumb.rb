class Breadcrumb
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "Breadcrumb"
    
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name]    
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties
  end
  
  def build_tool object
		WebClient::Wigets::Containers::Wrapper.new.set :component => WebClient::Tools::Breadcrumb
	end
end