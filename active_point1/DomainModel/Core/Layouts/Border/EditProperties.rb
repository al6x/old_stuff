class EditProperties < CPView
	build_view do |v|
		general = v.add :general, :attributes, :title => "General"
		v.root = general		
		
		aname = v.add :name, :string_edit
		general.add :name, aname
		
		acenter_container = v.add :center_container, :select, 
		:values => v.aparameters(:center_container)[:select]
		general.add :center_container, acenter_container
		
		aleft_container = v.add :left_container, :select, 
		:values => v.aparameters(:left_container)[:select]
		general.add :left_container, aleft_container
		
		atop_container = v.add :top_container, :select, 
		:values => v.aparameters(:top_container)[:select]
		general.add :top_container, atop_container
		
		aright_container = v.add :right_container, :select, 
		:values => v.aparameters(:right_container)[:select]
		general.add :right_container, aright_container
		
		abottom_container = v.add :bottom_container, :select, 
		:values => v.aparameters(:bottom_container)[:select]
		general.add :bottom_container, abottom_container
	end	
end