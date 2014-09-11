class System < Model::Entity
    attr_accessor :users, :groups
    
    def self.entity_name; "System" end
        
    METADATA = Model::Metadata.new
    METADATA.properties = [
        {:name => :name, :title => "Name", :type => :string, :mandatory => true},
        {:name => :users, :title => "Users", :type => :entity, :child => true},
        {:name => :groups, :title => "Groups", :type => :entity, :child => true}
    ] 
            
    METADATA.operations = [
        {:name => :manage_properties, :class => Model::Operations::Properties},
        {:name => :manage_users, :class => Model::Operations::Child,
            :property => :users, :select => lambda{[Users::Users]}},
        {:name => :manage_groups, :class => Model::Operations::Child,
            :property => :groups, :select => lambda{[Users::Groups]}}
    ]
end
	
class System    
    METADATA.properties = [
        {:editor => UI::Properties::EString},
        {:editor => UI::Properties::EEntity},
        {:editor => UI::Properties::EEntity}
    ]
        
    METADATA.operations = [
        {:dialog => UI::Operations::ManageProperties, :title => "Edit"},
        {:dialog => UI::Operations::ManageChild, :title => "Manage Users", :end_location => :current, 
            :select_labels => lambda{|o| o.entity_name}},
        {:dialog => UI::Operations::ManageChild, :title => "Manage Groups", :end_location => :current, 
            :select_labels => lambda{|o| o.entity_name}}
    ]
    
    METADATA.build
end