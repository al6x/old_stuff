class ShowAppearance < WComponent
	inherit Form
	
	build :tab, :component_id => :tab_appearance do
		set! :title => `Appearance`, :active => `Wigets`
		add `Wigets`, :box do
			line :wide => false do
				button :text => `Add`, :action => :add_wiget
				button :text => `Delete`, :action => [form, :delete_wigets] unless object.wigets.empty?
			end
			table :attr => :wigets, :selector => true do
				body{link :value => object}
			end
		end
		
		add `Layouts`, :box do
			line :wide => false do
				button :text => `Add`, :action => :add_layout
				button :text => `Delete`, :action => [form, :delete_layouts] unless object.layouts.empty?
			end
			table :attr => :layouts, :selector => true do
				body{link :value => object}
			end
		end
	end
end