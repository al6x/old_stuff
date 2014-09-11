class Site
	inherit Entity
	inherit ActivePoint::Core::Model::Secure
	inherit ActivePoint::Core::Model::Layout
	inherit ActivePoint::Core::Model::Skinnable
	
	metadata do 
		attribute :name, :string
		
	end
end