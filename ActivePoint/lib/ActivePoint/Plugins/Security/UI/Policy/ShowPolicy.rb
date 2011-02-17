class ShowPolicy < WComponent
	inherit Form
	
	build :tab, :component_id => "tab_policy" do
		set :title => object.name, :active => `Map`
		
		add `Map`, :box, :css => "padding" do
			head_values, matrix = Policy.map_to_matrix object.map
			table :value => matrix do
				
				head do
					head_values.each do |str|
						string_view :value => str # roles
					end
				end
				
				body do
					string_view :value => object[0] # permissions
					
					(head_values.size - 1).times do |i|
						string_view :value => object[i + 1]
					end					
				end
			end
			
			button :text => `Edit`, :action => :edit_map
		end
		
		add `Included In`, :box, :css => "padding" do
			table :attr => :included_in, :selector => false do
				body{link :value => object}
			end
		end
		
		add `Properties`, :box, :css => "padding" do
			button :text => `Edit`, :action => :edit_policy
		end
	end
end