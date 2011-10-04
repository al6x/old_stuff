class ShowGroup < WComponent
	inherit Form
	
	build :box do		
		tab :component_id => :group_tab, :active => `Users`, :title => object.name do
			add `Users`, :box do
				line :wide => false do
					button :text => `Add`, :action => :add_user
					button :text => `Delete`, :action => [form, :delete_user] unless object.users.empty?
				end
				table :selector => true, :attr => :users do
					head{string_view :value => ActivePoint::Plugins::Users::UI.to_l("Name")}
					body{link :value => object}					
				end
			end
			
			add `Groups`, :box do
				line :wide => false do
					button :text => `Add`, :action => :add_group
					button :text => `Delete`, :action => [form, :delete_group] unless object.groups.empty?
				end
				table :selector => true, :attr => :groups do
					head{string_view :value => ActivePoint::Plugins::Users::UI.to_l("Name")}
					body{link :value => object}
				end
			end
			
			add `Properties`, :attributes do
				list = new :table, :attr => :included_in do
					head{string_view :value => ActivePoint::Plugins::Users::UI.to_l("Name")}
					body{link :value => object}
				end
				add `Included In`, list
			end						
		end
		
		line :wide => false do
			button :text => `Edit`, :action => :edit_group
			button :text => `Delete`, :action => :delete_group
		end
	end
end