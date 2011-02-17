class Appearance
	inherit Entity
	LAYOUTS_DEFINITIONS = [Layouts::BorderLayout, Layouts::CustomLayout]
	
	metadata do
		name "Appearance"
		
		child :wigets, :bag
		child :layouts, :bag
	end
end