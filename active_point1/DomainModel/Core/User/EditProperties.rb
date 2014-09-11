class EditProperties < CPView
	build_view do |v|
		general = v.add :general, :attributes, :title => "General"
		v.root = general		
		
		aname = v.add :name, :string_edit 
		general.add :name, aname
		
		apassword = v.add :password, :string_edit, :password => true 
		general.add :password, apassword
	end	
end