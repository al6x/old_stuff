class Groups
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "Groups"
    
    m.attribute :groups, :entity, "Groups", :container => :array    
    m.operation :edit_groups, :edit_child,  "Edit Groups", 
      :attribute => :groups, :select => lambda{|current| [Group]}
    
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name]    
    
    m.children :groups
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties
    
    m.action :edit_groups, :edit_child, :titles => ["Add", "Delete"], 
    :edit_action => :on_edit, :go_to => :parent, :skip_if_single => true
  end
end

#class Groups < Model::Entity
#    attr_accessor :groups
#    
#    def self.entity_name; "Groups" end
#        
#    METADATA = Model::Metadata.new
#    METADATA.properties = [
#        {:name => :name, :title => "Name", :type => :string, :mandatory => true},
#        {:name => :groups, :title => "Groups", :type => :array, :child => true}
#    ] 
#            
#    METADATA.operations = [
#        {:name => :manage_properties, :class => Model::Operations::Properties},
#        {:name => :manage_groups, :class => Model::Operations::Child,
#            :property => :groups, :select => lambda{[Group]}}
#    ]
#end
#	
#class Groups    
#    METADATA.properties = [
#        {:editor => UI::Properties::EString},
#        {:editor => UI::Properties::ETable, :columns => [:name]}
#    ]
#        
#    METADATA.operations = [
#        {:dialog => UI::Operations::ManageProperties, :title => "Edit"},
#        {:dialog => UI::Operations::ManageChild, :title => "Manage Groups", :end_location => :current, 
#            :select_labels => lambda{|o| o.entity_name}}
#    ]
#    
#    METADATA.build   
#end