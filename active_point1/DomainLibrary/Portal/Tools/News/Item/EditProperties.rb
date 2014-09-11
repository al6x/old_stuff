class EditProperties < CPView
	build_view do |v|
		general = v.add :general, :attributes, :title => "General"
		v.root = general		
		
		aname = v.add :name, :string_edit
		general.add :name, aname
		
		alink = v.add :link, :string_edit, 
		:before_read => lambda{|e| e ? e.path.to_s : ""}, 
		:before_write => lambda{|s| 
			if s.empty?
				nil
			else								
				path = Path.new(s)
				e = v.metadata.storage[path]
				raise "Invalid Link Path (#{path})!" if e.path != path				
				e
			end
		}
		general.add :link, alink
		
		adate = v.add :date, :date_edit
		general.add :date, adate		
		
		atext = v.add :text, :text_edit
		general.add :text, atext
	end	
end