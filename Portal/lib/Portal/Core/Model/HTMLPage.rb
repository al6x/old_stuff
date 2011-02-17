class HTMLPage	
	inherit Entity, Locale
	inherit C::Model::Secure
	inherit C::Model::Layout
	
	metadata do
		name "HTMLPage"
		attribute :menu, :locale, :parameters => {:type => :string}
		attribute :html, :string
	end
	
	locale :menu
end