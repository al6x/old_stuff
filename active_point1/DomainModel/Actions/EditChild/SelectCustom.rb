class SelectCustom < SelectBase
	build_view do |v|
		attrs = v[:attrs]
    
    select = v.add :select, :string_edit 
    attrs.add "Select", select
	end	
end