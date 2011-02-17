class TextEdit < WTextArea
	include Editor
	
	alias_method :value, :text
	alias_method :value=, :text=	
end