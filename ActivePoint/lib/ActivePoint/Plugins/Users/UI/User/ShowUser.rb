class ShowUser < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `User`
		
		attributes do
			add `Name`, :string_view, :attr => :name
			add `Avatar`, :image_view, :attr => :avatar, :css => "icon"
			add `Details`, :richtext_view, :attr => :details
			
			list = new :table, :attr => :included_in do
				body{link :value => object}
			end
			add `Included In`, list
		end
		line :wide => false do
			button :text => `Edit`, :action => :edit_user
			button :text => `Delete`, :action => :delete_user
		end
	end
end