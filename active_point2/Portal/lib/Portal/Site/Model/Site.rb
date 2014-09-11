class Site
	inherit Entity, Locale
	inherit C::Model::Secure
	inherit C::Model::Layout
	inherit C::Model::Skinnable
	inherit Aspects::Model::Container
	
	metadata do 
		name "Site"
		attribute :logo, :locale, :parameters => {:type => :string}
		attribute :description, :locale, :parameters => {:type => :string}
		attribute :footer, :locale, :parameters => {:type => :string}
		attribute :menu, :locale, :parameters => {:type => :string}
	end
	
	locale :logo, :description, :footer
end