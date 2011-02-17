class Comment
	inherit Entity, Locale
	
	metadata do
		attribute :content, :locale, :parameters => {:type => :richtext}
		attribute :date, :date, :initialize => DateTime.now, 
		:validate => lambda{|date| raise "Empty Date!" unless date}
		
		reference :author		
		
		validate do
			author.should_not! :be_nil
		end
	end
	
	locale :content
end