class Content
  inherit OGDomain::Entity  
  
  build_dmeta do |m|
    m.entity_name "Content"
    
    m.attribute :menu, :entity, "Name"
    
    m.attribute :content, :string, "Content"
    
    m.attribute :content2, :richtext, "Content2"
        
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name, :content, :content2]    
    
    m.children :menu
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties    
  end
  
  def build_tool object  	
  	unless content.empty?
			WebClient::Wigets::Editors::TextView.new.set :value => content
		else
			WebClient::Wigets::Editors::RichTextView.new.set :value => content2
		end
  end
end