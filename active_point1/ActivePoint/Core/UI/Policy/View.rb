class View < WComponent
	inherit UView
	
	build_view do |v|
		form = v.new :box, :style => "float border_left border_top"		
		v.root = form
		
		tab = v.new :tab, :active => "Map", :title => v.object.name, :component_id => "policy_tab"
		form.add tab		
		tab.add "Map", build_map(v)
		tab.add "Details", build_details(v)			
	end
	
	class << self
		def build_map v			
			form = v.new :box			
			
			head, matrix = Policy.map_to_matrix v.object.map
			
			bview = lambda{|o| v.new :string_view, :value => o}
			perm_view = lambda{|o| v.new :string_view, :value => o}
			bvalue = lambda{|array, index| array[index]}
						
			values = []
			head.size.times{values << bvalue}
			editors = [perm_view]
			(head.size - 1).times{editors << bview}
									
			table = v.new :table, :selector => false, :head => head,
			:read_values => values, :editors => editors
			table.value = matrix
			form.add table
			
			form.add v.new(:button, :text => "Edit", :action => :edit_map)
			
			form
		end
		
		def build_details v
			attrs = v.new :attributes
			
			o_view = lambda do |o| 
				v.new :reference, :value => o, :text => o.entity_id
			end
			list = v.new :table, :name => :included_in, :selector => false,
			:read_values => [:self], :editors => [o_view]
			attrs.add "Included In", list
			
			attrs.add nil, v.new(:button, :text => "Edit", :action => :edit_policy)
			
			attrs
		end
	end
end