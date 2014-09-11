class ShowLayout < WComponent
	inherit Form
	
	build :attributes do
		set! :title => `Layout`
		object.should! :be_a, Model::Layout
		add `Layout`, [
		new(:link, :attr => :wc_layout),
		new(:button, :text => `Set`, :action => :layout_set)
		]
	end
end