class SitePage
	inherit Entity, Locale
	inherit Aspects::Model::Container
	inherit C::Model::Secure
	inherit C::Model::Layout
	
	metadata do
		name "Site Page"
		attribute :menu, :locale, :parameters => {:type => :string}		
		attribute :title, :locale, :parameters => {:type => :string}
		attribute :content, :locale, :parameters => {:type => :richtext}
	end
	
	locale :menu, :title, :content
end