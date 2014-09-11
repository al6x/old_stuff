class ToolsList < WComponent
	inherit UView
	
	build_view do |v|
		tools = v.new :box, :style => "float border_left border_top input padding", :title => "Tools"
		v.root = tools
		
		# Controls
		controls = v.new :flow, :style => "minimal color2"		
		tools.add controls		
		
		controls.add v.new(:button, :text => "Add", :action => :add_tool)
		unless v.object.tools.empty?
			controls.add v.new(:button, :text => "Delete", :action => [tools, :delete_tools])
		end
		
		# Tools
		tool_view = lambda do |u| 
			v.new :reference, :text => u.name, :value => u
		end
		list = v.new :table, :name => :tools,
		:read_values => [:self], :head => ["Name"], :editors => [tool_view]
		tools.add list
	end
end