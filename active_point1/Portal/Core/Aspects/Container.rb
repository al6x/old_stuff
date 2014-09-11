module Container
	inherit Entity
	
	metadata do
		child :children, :bag
	end
end