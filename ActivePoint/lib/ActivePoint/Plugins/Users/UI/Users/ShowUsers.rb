class ShowUsers < WComponent
	inherit Form
	
	build :tab, :component_id => :tab_users do
		set! :title => `Users`, :active => `Users`
		add `Users`, :box, :css => "padding" do
			line :wide => false do
				button :text => `Add`, :action => :add_user
				button :text => `Delete`, :action => [form, :delete_users] unless object.users.empty?
			end
			table :attr => :users, :selector => true do
				body do
					image_view :value => object.avatar, :css => "icon"
					link :value => object
				end
			end
		end
		
		add `Groups`, :box, :css => "padding" do
			line :wide => false do
				button :text => `Add`, :action => :add_group
				button :text => `Delete`, :action => [form, :delete_groups] unless object.groups.empty?
			end
			table :attr => :groups, :selector => true do
				body{link :value => object}
			end
		end
	end
end