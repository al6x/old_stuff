module View
	inherit UView
	
	build_view do |v|
		form = v.new :attributes, :title => "Skin"
		v.aspects.add form
		
		v.object.should! :be_a, Model::Skinnable
		skin = v.object.wc_skin
		editors = [v.new(:string_view, :name => :wc_skin)]
		editors << v.new(:button, :text => "Set", :action => :skin_set)
		if v.object.wc_skin and !v.object.wc_skin.empty?
			editors << v.new(:button, :text => "Delete", :action => :skin_delete)
		end
		form.add "Skin", editors
	end
end