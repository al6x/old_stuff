class SeleniumAdapter
	PATH_TO_FIREFOX = "#{CONFIG[:launcher]}"
	
	attr_reader :selenium
	
	def initialize
		#    SeleniumServer.instance.start
		@selenium = Selenium::SeleniumDriver.new(
            "localhost",
		4444,
		PATH_TO_FIREFOX,
                    "http://localhost",
		10000
		)
		begin
			@selenium.start
		rescue Exception => e
			raise e
		end
		@selenium.allow_native_xpath false
		@selenium.set_timeout(CONFIG[:timeout])
		@selenium.set_speed(CONFIG[:speed])
		clear_scope
	end
	
	def close
		@selenium.stop
		#@selenium.shut_down_selenium_server
		#SeleniumServer.instance.stop
	end
	
	def go url
		@selenium.open url
	end
	
	def go_back;
		@selenium.go_back
		wait_for_load
	end
	
	def refresh;
		@selenium.refresh
		wait_for_load
	end
	
	# "[['type', 'text'], [...], [...], [...]]" -> left/right/top/bottom
	
	def scope scope;
		scope = scope.collect do |a|
		(a.length == 2) ? "['#{normalize_text a[1]}', #{is_regexp? a[1]}, ['#{a[0]}']]" : "[]"
		end
		@scope = "[#{scope.join(', ')}]"
	end
	
	def clear_scope;
		@scope = "[[], [], [], []]"
	end
	
	# Click on element specified by Text
	
	def click text
		xpath = SeleniumAdapter.wait_for{element_search text, ['link', 'button']}
		@selenium.click "xpath=#{xpath}"
		wait_for_load
	end
	
	# Click on element specified by Fuzzy Search
	
	def fuzzy_click opt
		opt.text_types = [:any]
		xpath = SeleniumAdapter.wait_for{fuzzy_search(opt)}
		@selenium.click "xpath=#{xpath}"
		wait_for_load
	end
	
	# [textfield, textarea, file]
	
	def text opt
		opt.control_types = [:textfield, :textarea]
		opt.control_text = nil
		opt.text_types = [:text]
		xpath = SeleniumAdapter.wait_for{fuzzy_search(opt)}
		return @selenium.get_value("xpath=#{xpath}")
	end
	
	# TextField, TextArea, FileInput
	
	def type opt, text
		opt.control_types = [:textfield, :textarea, :file]
		opt.control_text = nil
		opt.text_types = [:text]
		xpath = SeleniumAdapter.wait_for{fuzzy_search(opt)}
		@selenium.type("xpath=#{xpath}", text)
	end
	
	# radiobutton, checkbox
	
	def checked? opt
		opt.control_types = [:radiobutton, :checkbox]
		opt.control_text = nil
		opt.text_types = [:text]
		xpath = SeleniumAdapter.wait_for{fuzzy_search(opt)}
		return @selenium.is_checked("xpath=#{xpath}")
	end
	
	# radiobutton, checkbox
	
	def check opt, checked
		opt.control_types = [:radiobutton, :checkbox]
		opt.control_text = nil
		opt.text_types = [:text]
		xpath = SeleniumAdapter.wait_for{fuzzy_search(opt)}

#		We can't use this approcach, becouse in WGUI Checkbox
#		uses JS hack, and we need explicitly click on it.
#		
#		if checked
#			@selenium.check("xpath=#{xpath}")			
#		else
#			@selenium.uncheck("xpath=#{xpath}")
#		end
		
		if checked					
			@selenium.click "xpath=#{xpath}" unless @selenium.is_checked("xpath=#{xpath}")
		else
			@selenium.click "xpath=#{xpath}" if @selenium.is_checked("xpath=#{xpath}")			
		end
	end
	
	# Select, Multiselect
	
	def select opt, options
		opt.control_types = [:select]
		opt.control_text = nil
		opt.text_types = [:text]
		xpath = SeleniumAdapter.wait_for{fuzzy_search(opt)}
		if options.size == 1
			begin
				# It raises Exception if it's the single-selection list.
				@selenium.remove_all_selections("xpath=#{xpath}")
			rescue
			end
			@selenium.select("xpath=#{xpath}", "label=#{options[0]}")
		else
			@selenium.remove_all_selections("xpath=#{xpath}")
			options.each do |o|
				@selenium.add_selection("xpath=#{xpath}", "label=#{o}")
			end
		end
	end
	
	# Select, Multiselect
	
	def unselect opt
		opt.control_types = [:select]
		opt.control_text = nil
		opt.text_types = [:text]
		xpath = SeleniumAdapter.wait_for{fuzzy_search(opt)}
		return @selenium.remove_all_selections("xpath=#{xpath}")
	end
	
	# Select, Multiselect
	
	def selection opt
		opt.control_types = [:select]
		opt.control_text = nil
		opt.text_types = [:text]
		xpath = SeleniumAdapter.wait_for{fuzzy_search(opt)}
		begin
			return @selenium.get_selected_values("xpath=#{xpath}")
		rescue RuntimeError => e
			if e.message =~ /No option selected/
				return []
			else
				raise e
			end
		end
	end
	
	def count_of_elements text, types
		script = %{\
Selenium.prototype.count_of_elements(\
window.document, \
"#{normalize_text text}", \
    #{is_regexp? text}, \
['#{types.join("', '")}'], \
    #{@scope}\
)}
		result = @selenium.get_eval(script)
		check_for_errors result
		return result.to_i
	end
	
	# Waits for condition
	def self.wait_for timeout = 0, &condition
		timeout = timeout == 0 ? CONFIG[:timeout] / 1000 : timeout
		start_time = Time.new
		e = RuntimeError.new("Waitings for specified Condition is out!")
		while Time.new - start_time <= timeout do
			begin
				result = condition.call
				return result if result
			rescue Exception => e
			end
			sleep 0.3
		end
		raise_without_self e.message, HOWT
	end
	
	private
	
	def wait_for_load
		#			@selenium.wait_for_page_to_load(CONFIG[:timeout])
	end
	
	# Finds for specied control with 'control_text' near the 'text' element and returns it xpath
	# text - Text for Text Element (required)
	# metric - [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] (required)
	# control_text - Text for Control Element (optional)
	# text_types - [button, link, textfield, textarea, select, radiobutton, checkbox, file, text, any] (required)
	# control_types - [button, link, textfield, textarea, select, radiobutton, checkbox, file, text, any] (required)
	
	def fuzzy_search opt
		script = %{Selenium.prototype.fuzzy_search(window.document, \
"#{normalize_text opt.text}", #{is_regexp? opt.text}, \
"#{opt.metric}", \
"#{normalize_text opt.control_text}", #{is_regexp? opt.control_text}, \
['#{opt.text_types.join("', '")}'], ['#{opt.control_types.join("', '")}'], \
    #{@scope}\
)}
		result = @selenium.get_eval(script).to_s
		check_for_errors result
		return result
	end
	
	def element_search text, types
		result = @selenium.get_eval(%{\
Selenium.prototype.element_search(\
window.document, \
"#{normalize_text text}", \
    #{is_regexp? text}, \
['#{types.join("', '")}'], \
    #{@scope}\
)})
		check_for_errors result
		return result
	end
	
	def check_for_errors result
		if result =~ /^ERROR_MESSAGE/
			raise result.gsub("ERROR_MESSAGE", "")
		end
	end
	
	def is_regexp? text;
		text; text.is_a? Regexp
	end
	
	def normalize_text text;
		is_regexp?(text) ? text.source : text
	end
end