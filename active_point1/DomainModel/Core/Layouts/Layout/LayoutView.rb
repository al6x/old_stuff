module LayoutView 
	inherit CPViewAspect
	build_view do |v|
		micelaneous = v[:micelaneous]		
		
		pane = v.add :layout_pane, :attributes
		micelaneous.add pane
		
		alayout = v.add :layout, :reference 
		pane.add :layout, [alayout, v.action(:edit_layout)]
	end
end