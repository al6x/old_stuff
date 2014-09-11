class Users
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "Users"
    
    m.attribute :users, :entity, "Users", :container => :array    
    m.operation :edit_users, :edit_child,  "Edit Users", 
      :attribute => :users, :select => lambda{|current| [User]}
    
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name]    
    
    m.children :users
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties
    
    m.action :edit_users, :edit_child, :titles => ["Add", "Delete"], 
    :edit_action => :on_edit, :go_to => :parent, :skip_if_single => true
  end
end








#class Users < Model::Entity
#    attr_accessor :users
#    
#    def self.entity_name; "Users" end
#        
#    METADATA = Model::Metadata.new
#    METADATA.properties = [
#        {:name => :name, :title => "Name", :type => :string, :mandatory => true},
#        {:name => :users, :title => "Users", :type => :array, :child => true}
#    ] 
#            
#    METADATA.operations = [
#        {:name => :manage_properties, :class => Model::Operations::Properties},
#        {:name => :manage_users, :class => Model::Operations::Child,
#            :property => :users, :select => lambda{[User]}}
#    ]
#end
#	
#class Users    
#    METADATA.properties = [
#        {:editor => UI::Properties::EString},
#        {:editor => UI::Properties::ETable, :columns => [:name]}
#    ]
#        
#    METADATA.operations = [
#        {:dialog => UI::Operations::ManageProperties, :title => "Edit"},
#        {:dialog => UI::Operations::ManageChild, :title => "Manage Users", :end_location => :current, 
#            :select_labels => lambda{|o| o.entity_name}}
#    ]
#    
#    METADATA.build   
#end