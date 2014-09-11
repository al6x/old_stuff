module Layout
  inherit OGDomain::Entity
  
  build_dmeta do |m|
    m.entity_name "Layout"
    
    m.attribute :layout, :entity, "Layout"    
		m.operation :edit_layout, :edit_reference,  "Edit Layout", :attribute => :layout, 
		:select => lambda{|current| storage.root.core.layouts.layouts}
  end
  
  build_vmeta do |m|        
    m.action :edit_layout, :edit_reference, :titles => ["Select", "Delete"]
  end
end