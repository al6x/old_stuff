class ShowSkinnable < WComponent
	inherit Form
	
	build :attributes do
		object.should! :be_a, Model::Skinnable
		
		set! :title => `Skin`
		add `Skin`, [
		new(:string_view, :attr => :wc_skin),
		new(:button, :text => `Set`, :action => :skin_set)
		]
	end
end