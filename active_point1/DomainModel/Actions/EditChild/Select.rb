class Select < SelectBase
  build_view do |v|
    attrs = v[:attrs]
    
    select = v.add :select, :select, :labels => lambda{|o| o.name}
    attrs.add "Select", select
  end 
end