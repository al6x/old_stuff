class ShowBorderLayout < WComponent
	inherit Form
	
	build :tab, :component_id => "tab_border_layout" do				
		set! :title => object.name, :active => `Layout`
		
		build_part = lambda do |position|
			new :box, :css => "border" do 
				line :wide => false do
					button :text => `Add`, :action => [:add_to, position]
					unless object.send(position).empty?
						button :text => `Delete`, :action => [form, :delete_from, position]
					end
				end
				
				table :attr => position, :selector => true do
					body do 
						link :value => object
					end
				end
			end			
		end
		
		add `Layout`, :border, :css => "padding" do
			center build_part.call(:center)
			left build_part.call(:left)
			top build_part.call(:top)
			right build_part.call(:right)
			bottom build_part.call(:bottom)
		end
		
		add `Properties`, :box do
			attributes do
				add `Name`, :string_view, :attr => :name
			end
			button :text => `Edit`, :action => :edit_layout
		end				
	end
end