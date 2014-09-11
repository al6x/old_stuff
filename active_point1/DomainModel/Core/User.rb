class User
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "User"
    
    m.attribute :password, :string, "Password"
    
    m.attribute :included_in, :entity, "Included In", :container => :array 
    
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name, :password]    
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties
  end
end

#class User < Model::Entity
#    attr_accessor :password, :included
#    
#    def self.entity_name; "User" end
#        
#    METADATA = Model::Metadata.new
#    METADATA.properties = [
#        {:name => :name, :title => "Name", :type => :string, :mandatory => true},
#        {:name => :password, :title => "Password", :type => :string, :mandatory => true},
#        {:name => :included, :title => "Included", :type => :array}
#    ] 
#            
#    METADATA.operations = [
#        {:name => :manage_properties, :class => Model::Operations::Properties}
#    ]
#end
#	
#class User    
#    METADATA.properties = [
#        {:editor => UI::Properties::EString},
#        {:editor => UI::Properties::EString},
#        {:editor => UI::Properties::ETable, :columns => [:name]}
#    ]
#        
#    METADATA.operations = [
#        {:dialog => UI::Operations::ManageProperties, :title => "Edit"}
#    ]
#    
#    METADATA.build    
#end