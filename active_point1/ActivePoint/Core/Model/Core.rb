class Core
	inherit Entity
	
	metadata do
		child :plugins, :bag
	end
end