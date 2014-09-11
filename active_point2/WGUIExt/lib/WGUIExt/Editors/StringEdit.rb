class StringEdit < WTextField
	include Editor
	
	alias_method :value, :text
	alias_method :value=, :text=
end