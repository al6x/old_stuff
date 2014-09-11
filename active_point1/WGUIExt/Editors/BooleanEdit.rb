class BooleanEdit < WCheckbox
	include Editor
	
	alias_method :value, :selected
	alias_method :value=, :selected=
end