class Post
	inherit Entity, Locale
	
	metadata do
		attribute :title, :locale, :parameters => {:type => :string}
		attribute :icon, :object
		attribute :details, :locale, :parameters => {:type => :string}
		attribute :date, :date, :initialize => DateTime.now, 
		:validate => lambda{|date| raise "Empty Date!" unless date}
		attribute :content, :locale, :parameters => {:type => :richtext}
		
		child :comments, :bag
		
		reference :author
		
		validate do
			author.should_not! :be_nil
		end
	end
	
	locale :title, :details, :content
end