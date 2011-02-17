module Container
	inherit Entity
	
	CONTENT_TYPES = []
	
	metadata do
		child :items, :bag
	end
end