class EditMap < WComponent
	inherit UView
	
	attr_accessor :on_ok, :on_cancel, :table
	
	build_view do |v|
		form = v.new :box, :style => "float padding border_top border_left", :title => "Edit Security Map"
		v.root = form
		
		controls = v.new :flow, :style => "minimal padding color2"
		form.add controls
		controls.add v.new(:button, :text => "Edit Groups", :action => [form, :edit_groups])
		controls.add v.new(:button, :text => "Edit Permissions", :action => [form, :edit_permissions])
		
		head, matrix = v.object[:head], v.object[:matrix]

		bview = lambda{|o| v.new :select, :value => o, :values => ["yes", "no", ""]}
		perm_view = lambda{|o| v.new :string_view, :value => o}
		bvalue = lambda{|array, index| array[index]}
		
		read_values = []
		(head.size).times{read_values << bvalue}
		editors = [perm_view]
		(head.size - 1).times{editors << bview}
		
		v.table = v.new :table, :selector => false, :head => head,
		:read_values => read_values,  :editors => editors
		v.table.value = matrix
		form.add v.table
		
		controls2 = v.new :flow, :style => "minimal padding"
		form.add controls2
		controls2.add v.new(:button, :text => "Ok", :action => [form, v.on_ok])
		controls2.add v.new(:button, :text => "Cancel", :action => v.on_cancel)
	end
end