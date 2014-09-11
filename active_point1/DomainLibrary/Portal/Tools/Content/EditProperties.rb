class EditProperties < CPView
	build_view do |v|
		general = v.add :general, :attributes, :title => "General"
		v.root = general		
		
		aname = v.add :name, :string_edit 
		general.add :name, aname
		
		acontent = v.add :content, :text_edit
		general.add :content, acontent
		
		acontent2 = v.add :content2, :richtext_edit
		general.add :content2, acontent2
	end	
end