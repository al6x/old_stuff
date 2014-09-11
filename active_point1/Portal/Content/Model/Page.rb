class Page
	inherit Entity, Aspects::Container
	
	metadata do
		attribute :title, :string
		attribute :content, :object, :initialize => lambda{WGUIExt::Editors::RichTextData.new}
		child :pages, :bag
	end
end