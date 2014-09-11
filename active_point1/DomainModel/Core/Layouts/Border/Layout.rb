class Layout < CPView
	attr_accessor :object, :parameters
	
	build_view do |v|		
		root = v.add :border, :border
		v.root = root
		
		unless v.parameters.center_tools.empty?
			center_container = v.add :center_container, v.parameters.center_container, :padding => true
			v.parameters.center_tools.each do |tool|
				center_container.add tool.build_tool(v.object)
			end
			root.add :center, center_container
		end
		
		unless v.parameters.left_tools.empty?
			left_container = v.add :left_container, v.parameters.left_container, :padding => true
			v.parameters.left_tools.each do |tool|
				left_container.add tool.build_tool(v.object)
			end
			root.add :left, left_container
		end
		
		unless v.parameters.top_tools.empty?
			top_container = v.add :top_container, v.parameters.top_container, :padding => true
			v.parameters.top_tools.each do |tool|
				top_container.add tool.build_tool(v.object)
			end
			root.add :top, top_container		
		end
		
		unless v.parameters.right_tools.empty?
			right_container = v.add :right_container, v.parameters.right_container, :padding => true
			v.parameters.right_tools.each do |tool|				
				right_container.add tool.build_tool(v.object)
			end
			root.add :right, right_container
		end
		
		unless v.parameters.bottom_tools.empty?
			bottom_container = v.add :bottom_container, v.parameters.bottom_container, :padding => true
			v.parameters.bottom_tools.each do |tool|
				bottom_container.add tool.build_tool(v.object)
			end
			root.add :bottom, bottom_container		
		end
	end
end