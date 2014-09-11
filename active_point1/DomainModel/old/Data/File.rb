class File < Model::Entity
    attr_accessor :name, :extension, :size, :file
    
    def self.entity_name; "File" end
        
    METADATA = Model::Metadata.new
    METADATA.properties = [
        {:name => :name, :title => "Name", :type => :string, :mandatory => true},
        {:name => :extension, :title => "Extension", :type => :string, :mandatory => true},
        {:name => :size, :title => "Size", :type => :number, :mandatory => true},
        {:name => :file, :title => "Data", :type => :file, :mandatory => true}
    ] 
            
    METADATA.operations = [
        {:name => :manage_properties, :class => Model::Operations::Properties}
    ]
end
	
class User    
    METADATA.properties = [
        {:editor => UI::Properties::EString},
        {:editor => UI::Properties::EString},
        {:editor => UI::Properties::ENumber},
        {:editor => UI::Properties::EFile}
    ]
        
    METADATA.operations = [
        {:dialog => UI::Operations::ManageProperties, :title => "Edit"}
    ]
    
    METADATA.build    
end