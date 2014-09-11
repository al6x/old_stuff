class View < WComponent
	inherit UView
	
	build_view do |v|
		core = v.new :attributes, :style => "float border_left border_top input padding", :title => "Core"
		v.root = core

		# Plugins
		plugin_view = lambda do |pl| 
			v.new :reference, :text => pl.entity_id, :value => pl
		end
		list = v.new :table, :name => :plugins, :selector => false,
		:read_values => [:self], :editors => [plugin_view]
		core.add "Plugins", list
	end
end