module View
	inherit UView
	
	build_view do |v|
		form = v.new :attributes, :title => "Layout"
		v.aspects.add form
		
		v.object.should! :be_a, Model::Layout
		sp = v.object.wc_layout
		editors = [v.new(:reference, :name => :wc_layout, :text => (sp ? sp.name : ""))]
		editors << v.new(:button, :text => "Set", :action => :layout_set)
		if v.object.wc_layout
			editors << v.new(:button, :text => "Delete", :action => :layout_delete)
		end
		form.add "Layout", editors
	end
end