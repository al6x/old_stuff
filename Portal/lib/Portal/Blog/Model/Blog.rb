class Blog
	inherit Entity, Locale
	inherit C::Model::Secure
	inherit C::Model::Layout
	inherit C::Model::Skinnable	
	
	metadata do			
		name "Blog"
		attribute :menu, :locale, :parameters => {:type => :string}
		attribute :title, :locale, :parameters => {:type => :string}
		attribute :sorting_order, :string
		child :posts, :bag #, :validate => lambda{|p| p.is_a? Post}
	end
	
	locale :menu, :title
end