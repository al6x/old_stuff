class View < WComponent
	inherit UView
	
	build_view do |v|
		form = v.new :box, :style => "float border_left border_top input padding", :title => v.object.name
		v.root = form
		
		border = v.new :border, :style => "float border"
		form.add border
		
		border.add :left, build_part(:left, v)
		border.add :center, build_part(:center, v)		
		border.add :top, build_part(:top, v)
		border.add :right, build_part(:right, v)
		border.add :bottom, build_part(:bottom, v)
		
		controls = v.new :flow, :style => "minimal input padding"
		form.add controls		
		controls.add v.new(:button, :text => "Edit", :action => :edit_layout)
	end
	
	class << self
		def build_part position, v
			form = v.new :box, :style => "float border padding"
			
			# Controls
			controls = v.new :flow, :style => "minimal color2"		
			form.add controls		
			
			controls.add v.new(:button, :text => "Add", :action => :"add_to_#{position}")
			unless v.object.send(position).empty?
				controls.add v.new(:button, :text => "Delete", :action => [form, :"delete_from_#{position}"])
			end
			
			# Tools
			tools_view = lambda do |t| 
				v.new :reference, :text => t.name, :value => t
			end
			list = v.new :table, :name => position,
			:read_values => [:self], :head => ["Tool"], :editors => [tools_view]
			form.add list
			
			return form
		end
	end
end