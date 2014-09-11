class Blog
	inherit Entity
	inherit ActivePoint::Core::Model::Secure
	inherit ActivePoint::Core::Model::Layout
	inherit ActivePoint::Core::Model::Skinnable
	
	metadata do				
		attribute :title, :string
		attribute :sorting_order, :string
		child :posts, :bag #, :validate => lambda{|p| p.is_a? Post}
	end
end