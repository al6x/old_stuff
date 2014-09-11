class EditProperties < CPView
	build_view do |v|
		general = v.add :general, :attributes
		v.root = general		
		
		aname = v.add :name, :string_edit 
		general.add :name, aname
		
		atext = v.add :text, :richtext_edit 
		general.add nil, atext
	end	
end