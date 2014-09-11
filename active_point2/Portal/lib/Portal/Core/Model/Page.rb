class Page
	inherit Entity, Aspects::Model::Container, Locale
	inherit C::Model::Secure
	
	metadata do
		name "Page"
		attribute :menu, :locale, :parameters => {:type => :string}
		attribute :content, :locale, :parameters => {:type => :richtext}
	end
	
	locale :content, :menu
end