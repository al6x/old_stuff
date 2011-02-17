class Portal
	inherit Entity, Locale
	inherit C::Model::Secure
	inherit C::Model::Layout
	inherit C::Model::Skinnable
	inherit Aspects::Model::Container
	
	metadata do 		
		name "Portal"	
		attribute :content, :locale, :parameters => {:type => :richtext}
		child :core
	end
	
	locale :content
end