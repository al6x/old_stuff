class LayoutDefinition
	inherit Entity
	
	metadata do
		reference :center, :bag		
		reference :left, :bag
		reference :top, :bag
		reference :right, :bag
		reference :bottom, :bag
	end
	
	def build_layout
		layout = WGUIExt::Containers::Border.new
		[:center, :left, :top, :right, :bottom].each do |pos|
			list = self.send pos			
			next if list.empty?
			
			box = WGUIExt::Containers::Box.new
			layout.add pos, box
			
			list.each do |tool_def| 
				tool = tool_def.build_tool
				box.add tool
			end
		end
		return layout
	end
	
	alias_method :name, :entity_id
	alias_method :name=, :entity_id=
end