class Queries
	def initialize browser
		@browser = browser
	end
	
	# text
	def text text = ""		
		selector = CONFIG[:text_selector].should!(:be_a, String).should_not!(:be_empty)		
		if text.is_a? String and text.empty?
			%{//*[contains(@class, '#{selector}')]}
		else
			%{\
//*[name(.) != 'OPTION' and name(.) != 'TEXTAREA' and name(.) != 'BUTTON' and #{match("text()", text)}]|\
//*[contains(@class, '#{selector}') and #{match("text()", text)}]}
		end
	end
	
	def button text = ""
		if text.is_a?(String) and text.empty?
			"//input[(@type = 'button' or @type = 'submit')]|//button"
		else
			%{\
//input[#{match("@value", text)} and (@type = 'button' or @type = 'submit')]|\
//button[#{match("@value", text)} or #{match("text()", text)}]}
		end	
	end		
	
	def link text = ""
		if text.is_a?(String) and text.empty?
			"//a"
		else
			%{//a[#{match("text()", text)}]}
		end
	end
	
	# textarea, textfield, file
	def text_input text = ""
		#		%{//input[@type = 'text']|//textarea|//input[@type = 'file']}
		if text.is_a?(String) and text.empty?				
			%{//input[@type = 'text' or @type = 'file']|//textarea}
		else
			%{\
//input[#{match("@value", text)} and (@type = 'text' or @type = 'file')]|\
//textarea[#{match("text()", text)}]}
		end
	end
	
	# checkbox, radiobutton
	def check 
		%{//input[@type = 'radio' or @type = 'checkbox']}
	end
	
	# select, multiselect
	def select 
		%{//select}
	end		
	
	def any text = ""		
		list = [button(text), check, link(text), select, text(text), text_input]
		list.join("|")
	end
	
	def control text = ""
		[button(text), link(text)].join("|")
	end
	
	protected
	def match match, value			
		match.should! :be_a, String
		if value.is_a? Regexp
			%{contains(#{match}, '#{value.source}')}
		else
			value.should! :be_a, String
			%{#{match} = '#{value}'}
		end
	end
end