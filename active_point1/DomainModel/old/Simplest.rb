class Simplest < Model::Entity
    attr_accessor :select, :child, :country, :children, :reference, :references, :breference, :breferences, :rich, :file
    
    def self.entity_name; "Simplest" end
        
    METADATA = Model::Metadata.new
    METADATA.properties = [
        {:name => :name, :title => "Name", :type => :string, :mandatory => true},
        {:name => :select, :title => "Select", :type => :string, :select => lambda{["USA", "Australia"]}},
        {:name => :child, :title => "Child", :type => :entity, :child => true},
        {:name => :children, :title => "Children", :type => :array, :child => true},
        {:name => :reference, :title => "Reference", :type => :entity},
        {:name => :references, :title => "References", :type => :array},
        {:name => :breference, :title => "BReference", :type => :entity},
        {:name => :breferences, :title => "BReferences", :type => :array},
        {:name => :rich, :title => "Rich", :type => :text},
        {:name => :file, :title => "File", :type => :file}
        # reference
        # 
        # table of references
    ] 
            
    METADATA.operations = [
        {:name => :manage_properties, :class => Model::Operations::Properties},
        {:name => :manage_child, :class => Model::Operations::Child,
            :property => :child, :select => lambda{[Simplest]}},
        {:name => :manage_children, :class => Model::Operations::Child,
            :property => :children, :select => lambda{[Simplest]}},
        {:name => :manage_reference, :class => Model::Operations::Reference,
            :property => :reference, :select => lambda{Scope[Model::Entity].children}},
        {:name => :manage_references, :class => Model::Operations::Reference,
            :property => :references, :select => lambda{Scope[Model::Entity].children}},
        {:name => :manage_breference, :class => Model::Operations::BReference,
            :property => :breference, :reference_property => :breference, 
            :select => lambda{Scope[Model::Entity].children}},
        {:name => :manage_breferences, :class => Model::Operations::BReference,
            :property => :breferences, :reference_property => :breferences,
            :select => lambda{Scope[Model::Entity].children}}
    ]
end
	
class Simplest    
    METADATA.properties = [
        {:editor => UI::Properties::EString},
        {:editor => UI::Properties::ESelect, :select_labels => lambda{|o| o.to_s}},
        {:editor => UI::Properties::EEntity},
        {:editor => UI::Properties::ETable, :columns => [:name, :select]},
        {:editor => UI::Properties::EEntity},
        {:editor => UI::Properties::ETable, :columns => [:name, :select]},
        {:editor => UI::Properties::EEntity},
        {:editor => UI::Properties::ETable, :columns => [:name, :select]},
        {:editor => UI::Properties::ERichText},
        {:editor => UI::Properties::EFile}
    ]
        
    METADATA.operations = [
        {:dialog => UI::Operations::ManageProperties, :title => "Edit"},
        {:dialog => UI::Operations::ManageChild, :title => "Manage Child", :end_location => :child, 
            :select_labels => lambda{|o| o.entity_name}},
        {:dialog => UI::Operations::ManageChild, :title => "Manage Children", :input => true, :end_location => :current, 
            :select_label => "Select Class", :not_selected => "Child isn't selected!", 
            :select_labels => lambda{|o| o.entity_name}}, 
        {:dialog => UI::Operations::ManageReference, :title => "Manage Reference", :end_location => :reference, 
            :select_labels => lambda{|o| o.name}},
        {:dialog => UI::Operations::ManageReference, :title => "Manage References", :input => true, :end_location => :current, 
            :select_label => "Select Object", :not_selected => "Object isn't selected!", :select_labels => lambda{|o| o.name}}, 
        {:dialog => UI::Operations::ManageReference, :title => "Manage BReference", :end_location => :reference, 
            :select_labels => lambda{|o| o.name}},
        {:dialog => UI::Operations::ManageReference, :title => "Manage BReferences", :input => true, :end_location => :current, 
            :select_label => "Select Object", :not_selected => "Object isn't selected!", :select_labels => lambda{|o| o.name}}
    ]
    
    METADATA.build
end


#        state [:Created, :delete, :Deleted]      
#class Test
#	property :items do
#		control :add do
#			label "Add"
#			action do |context|
#				context.tmp_object = UObject.instance(Item)
#				context.get do |new_object|
#					copy
#					items << new_object
#					new_object.parent = self
#					commit
#				end				
#            end
#        end
#		
#		control :delete do
#			label "Delete"
#			action do |context|
#				context.selection.each do |item|
#					copy
#					items user
#					commit
#                end
#            end
#        end
#    end
#		
#	control :creation_create do
#		label "Create"
#		active :Creation
#		action do |context|					
#			#			state.create # Not needed, will be done automatically because of 'initial_state'
#			context.return self
#        end
#    end
#	
#	control :creation_cancel do
#		label "Cancel"
#		active :Creation
#		action do |context|
#			context.return
#        end
#    end
#	
#	control :edit do
#		label "Edit"
#		active :View
#		action do |context|
#			copy
#			context.mode = :edit # Need this explicitly, because we need the ':edit' mode not only in ':edit' state.
#			state.edit
#        end
#    end
#	
#	control :edit_save do
#		label "Save"
#		active :Edit
#		action do |context|		
#			context.mode = :view
#			state.save
#			commit
#        end
#    end
#	
#	control :edit_cancel do
#		label "Cancel"
#		active :Edit
#		action do |context|
#			context.mode = :view
#			#			state.cancel # not needed, will do it automatically because of 'rollback'
#			rollback
#        end
#    end
#	
#	control :delete do
#		label "Delete"
#		active :View
#		action do |context|			
#			copy
#			state.delete
#			commit
#			context.object = parent
#        end
#    end
#end