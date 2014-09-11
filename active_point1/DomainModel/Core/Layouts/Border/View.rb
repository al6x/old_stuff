class View < DomainModel::Actions::View::Form
	build_view do |v|
		tab = v[:tab]		
		tab.active = "Containers"
		tab.disabled_tabs "Attributes", "Micelaneous"
		
		# Containers
		containers = v.add :containers, :attributes
		tab.add "Containers", containers, -2
		
		containers.add nil, v.action(:on_edit)
								
		acenter_container = v.add :center_container, :string_view, :before_read => lambda{|o| o.to_s}
		containers.add :center_container, acenter_container
		
		aleft_container = v.add :left_container, :string_view, :before_read => lambda{|o| o.to_s}
		containers.add :left_container, aleft_container
		
		atop_container = v.add :top_container, :string_view, :before_read => lambda{|o| o.to_s}
		containers.add :top_container, atop_container		
		
		aright_container = v.add :right_container, :string_view, :before_read => lambda{|o| o.to_s}
		containers.add :right_container, aright_container
		
		abottom_container = v.add :bottom_container, :string_view, :before_read => lambda{|o| o.to_s}
		containers.add :bottom_container, abottom_container
		
		# Tools
		tools = v.add :tools, :border, :padding => true
		tab.add "Tools", tools, -1	
		
		entity_reference_view = lambda do |value| 
      e = v.create :reference
      e.value = value
      e
    end 
            
    # Center
		center_tools_container = v.add :center_tools_container, :box, :padding => true, :border => true    
    
    center_tools_table = v.add :center_tools, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [entity_reference_view]            
    
    edit_center_tools = v.action :edit_center_tools, :inputs => center_tools_table, 
		:selected => lambda{center_tools_table.selected}
		
		center_tools_container.add edit_center_tools
		center_tools_container.add center_tools_table
    
    tools.add :center, center_tools_container
    
    # Left
		left_tools_container = v.add :left_tools_container, :box, :padding => true, :border => true    
    
    left_tools_table = v.add :left_tools, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [entity_reference_view]            
    
    edit_left_tools = v.action :edit_left_tools, :inputs => left_tools_table, 
		:selected => lambda{left_tools_table.selected}
		
		left_tools_container.add edit_left_tools
		left_tools_container.add left_tools_table
    
    tools.add :left, left_tools_container
    
    # Top
		top_tools_container = v.add :top_tools_container, :box, :padding => true, :border => true
    
    top_tools_table = v.add :top_tools, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [entity_reference_view]            
    
    edit_top_tools = v.action :edit_top_tools, :inputs => top_tools_table, 
		:selected => lambda{top_tools_table.selected}
		
		top_tools_container.add edit_top_tools
		top_tools_container.add top_tools_table
    
    tools.add :top, top_tools_container
    
    # Right
		right_tools_container = v.add :right_tools_container, :box, :padding => true, :border => true    
    
    right_tools_table = v.add :right_tools, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [entity_reference_view]            
    
    edit_right_tools = v.action :edit_right_tools, :inputs => right_tools_table, 
		:selected => lambda{right_tools_table.selected}
		
		right_tools_container.add edit_right_tools
		right_tools_container.add right_tools_table
    
    tools.add :right, right_tools_container
    
    # Bottom
		bottom_tools_container = v.add :bottom_tools_container, :box, :padding => true, :border => true    
    
    bottom_tools_table = v.add :bottom_tools, :table_view, :head => ["Name"], 
    :values => [:self], :editors => [entity_reference_view]            
    
    edit_bottom_tools = v.action :edit_bottom_tools, :inputs => bottom_tools_table, 
		:selected => lambda{bottom_tools_table.selected}
		
		bottom_tools_container.add edit_bottom_tools
		bottom_tools_container.add bottom_tools_table
    
    tools.add :bottom, bottom_tools_container
	end
end