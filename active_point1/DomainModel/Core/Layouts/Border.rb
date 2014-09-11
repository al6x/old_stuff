class Border
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "Border"    
    
    m.attribute :center_container, :object, "Center", :initialize => :box, 
    :parameters => {:select => [:box, :flow]}
    m.attribute :center_tools, :entity, "Center", :container => :array
    m.operation :edit_center_tools, :edit_reference,  "Edit Center", :attribute => :center_tools, 
		:select => lambda{|current| storage.root.core.tools.tools}
    
    m.attribute :left_container, :object, "Left", :initialize => :box, 
    :parameters => {:select => [:box, :flow]}
    m.attribute :left_tools, :entity, "Left", :container => :array
    m.operation :edit_left_tools, :edit_reference,  "Edit Left", :attribute => :left_tools, 
		:select => lambda{|current| storage.root.core.tools.tools}
    
    m.attribute :top_container, :object, "Top", :initialize => :box, 
    :parameters => {:select => [:box, :flow]}
    m.attribute :top_tools, :entity, "Top", :container => :array
    m.operation :edit_top_tools, :edit_reference,  "Edit Top", :attribute => :top_tools, 
		:select => lambda{|current| storage.root.core.tools.tools}
    
    m.attribute :right_container, :object, "Right", :initialize => :box, 
    :parameters => {:select => [:box, :flow]}
    m.attribute :right_tools, :entity, "Right", :container => :array
    m.operation :edit_right_tools, :edit_reference,  "Edit Right", :attribute => :right_tools, 
		:select => lambda{|current| storage.root.core.tools.tools}
    
    m.attribute :bottom_container, :object, "Bottom", :initialize => :box, 
    :parameters => {:select => [:box, :flow]}
    m.attribute :bottom_tools, :entity, "Bottom", :container => :array    
    m.operation :edit_bottom_tools, :edit_reference,  "Edit Bottom", :attribute => :bottom_tools, 
		:select => lambda{|current| storage.root.core.tools.tools}
    
    m.operation :on_edit, :edit_properties, "Edit Properties", 
    :attributes => [:name, :center_container, :left_container, :top_container, 
    :right_container, :bottom_container]    
  end
  
  build_vmeta do |m|
    m.action :on_view, :view, :form => View
    
    m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties
    
    m.action :edit_center_tools, :edit_reference, :titles => ["Select", "Delete"]
		
		m.action :edit_left_tools, :edit_reference, :titles => ["Select", "Delete"]
		
		m.action :edit_top_tools, :edit_reference, :titles => ["Select", "Delete"]
		
		m.action :edit_right_tools, :edit_reference, :titles => ["Select", "Delete"]
		
		m.action :edit_bottom_tools, :edit_reference, :titles => ["Select", "Delete"]
  end
  
  def build_layout object
  	Border::Layout.new :object => object, :parameters => self
  end
end