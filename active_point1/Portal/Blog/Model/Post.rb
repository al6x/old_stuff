class Post
	inherit Entity
	
	metadata do
		attribute :title, :string
		attribute :icon, :object
		attribute :details, :string
		attribute :date, :date, :initialize => lambda{DateTime.now}, 
		:validate => lambda{|date| raise "Empty Date!" unless date}
		attribute :content, :object, :initialize => lambda{WGUIExt::Editors::RichTextData.new}
	end
end