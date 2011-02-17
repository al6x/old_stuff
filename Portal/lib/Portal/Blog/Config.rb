class Config
	extend Configurator
	
	activate do
		Aspects::Model::Container::CONTENT_TYPES << Model::Blog
	end
end