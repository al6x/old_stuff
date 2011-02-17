class Core
	inherit Entity
	inherit Appearance::Model::Layout
	inherit Appearance::Model::Skinnable
	inherit Security::Model::Secure
	
	metadata do
		name "Core"
		child :plugins, :bag
	end
end