class Group
	inherit OGDomain::Entity
	
	build_dmeta do |m|
		m.entity_name "Group"
		
		m.attribute :included_in, :entity, "Included In", :container => :array    
		
		m.attribute :groups, :entity, "Groups", :container => :array    
		m.operation :edit_groups, :edit_breference,  "Edit Groups", :attribute => :groups, 
		:reference_attribute => :included_in, :select => (lambda do |current| 
			selected = current.groups
			storage.root.core.groups.groups.select{|g| g != current and !selected.include?(g)}
		end)
		
		m.attribute :users, :entity, "Users", :container => :array    
		m.operation :edit_users, :edit_breference,  "Edit Users", :attribute => :users, 
		:reference_attribute => :included_in, :select => (lambda do |current| 
			selected = current.users
			storage.root.core.users.users.select{|u| u != current and !selected.include?(u)}
		end)
		
		m.operation :on_edit, :edit_properties, "Edit Properties", 
		:attributes => [:name]    
	end
	
	build_vmeta do |m|
		m.action :on_view, :view, :form => View
		
		m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties
		
		m.action :edit_groups, :edit_reference, :titles => ["Select", "Delete"]
		
		m.action :edit_users, :edit_reference, :titles => ["Select", "Delete"]
	end
end

#class Group < Model::Entity
#    attr_accessor :groups, :users, :included
#    
#    def self.entity_name; "Group" end
#        
#    METADATA = Model::Metadata.new
#    METADATA.properties = [
#        {:name => :name, :title => "Name", :type => :string, :mandatory => true},
#        {:name => :groups, :title => "Groups", :type => :array},
#        {:name => :users, :title => "Users", :type => :array},
#        {:name => :included, :title => "Included", :type => :array}
#    ] 
#            
#    METADATA.operations = [
#        {:name => :manage_properties, :class => Model::Operations::Properties},
#        {:name => :manage_users, :class => Model::Operations::BReference,
#            :property => :users, :reference_property => :included, 
#            :select => lambda{Scope[Model::Repository].root.system.users.users}},
#        {:name => :manage_groups, :class => Model::Operations::BReference,
#            :property => :groups, :reference_property => :included, 
#            :select => lambda{Scope[Model::Repository].root.system.groups.groups}}
#    ]
#end
#	
#class Group    
#    METADATA.properties = [
#        {:editor => UI::Properties::EString},
#        {:editor => UI::Properties::ETable, :columns => [:name]},
#        {:editor => UI::Properties::ETable, :columns => [:name]},
#        {:editor => UI::Properties::ETable, :columns => [:name]}
#    ]
#        
#    METADATA.operations = [
#        {:dialog => UI::Operations::ManageProperties, :title => "Edit"},
#        {:dialog => UI::Operations::ManageReference, :title => "Manage Users", :end_location => :current, 
#            :select_labels => lambda{|o| o.name}},
#        {:dialog => UI::Operations::ManageReference, :title => "Manage Groups", :end_location => :current, 
#            :select_labels => lambda{|o| o.name}}
#    ]
#    
#    METADATA.build   
#end