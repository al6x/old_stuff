class Form < CPView
	build_view do |v|
		tab = v.add :tab, :tab, :active => "Attributes"
		v.root = tab
		
		# Name
		aname = v.add :name, :string_view
		tab.title = aname				
		
		attributes = v.add :attributes, :box, :padding => true
		tab.add "Attributes", attributes
		
		attributes_toolbar = v.add :attributes_toolbar, :flow, :floating => true, :padding => true, :highlithed => true
		attributes.add attributes_toolbar
		
		micelaneous = v.add :micelaneous, :box, :padding => true
		tab.add "Micelaneous", micelaneous
	end
end