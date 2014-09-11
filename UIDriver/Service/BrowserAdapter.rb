class BrowserAdapter		
	include Expirable
	inherit RubyExt::Synchronizer, Log		
	PAGE_AVAILABLE = "window.uidriver_page_available"
	
	def initialize
		super
		@selenium = SeleniumService.create_selenium_dirver
		@selenium.start
		@selenium.allow_native_xpath false		
		@config = Hash.new{|hash, key| raise "No key '#{key}'!"}
	end
	
	def configure args				
		[:timeout, :speed, :browser_expires, :retry_timeout, 
		:auto_wait].collect{|n| n.to_s}.every.should! :be_in, args
		ws_configure args
	end
	
	def ws_configure args
		if args[:timeout]
			timeout = args[:timeout].should_not!(:be_nil).to_f	
			@config[:timeout] = timeout
			@selenium.set_timeout(selenium_timeout)			
		end
		
		@selenium.set_speed((args[:speed].should_not!(:be_nil).to_f * 1000).round) if args[:speed]		
		expires_after args[:browser_expires].to_f if args[:browser_expires]
		@config[:retry_timeout] = args[:retry_timeout].should_not!(:be_nil).to_f if args[:retry_timeout]
		@config[:auto_wait] = args[:auto_wait].should_not!(:be_nil) == "true" if args[:auto_wait]
		
		return ""
	end
	
#	def ws_close args
#		get_alert
#		
#		close
#		return ""
#	end
#	
#	def ws_break args
#		get_alert
#		
#		@selenium.do_command("break", [])
#		return ""
#	end	
	
	def ws_go args
		get_alert
		url = args[:url].should_not!(:be_nil).should_not!(:be_empty)
		url = (url =~ /(^http:)|(^file:)/) ? url : "http://#{url}"
		
		@selenium.open url
		wait_for_load
		return ""
	end
	
	def ws_uri args
		get_alert
		
		CGI.unescape(@selenium.get_location)
	end
	
	def ws_go_back args
		get_alert
		
		@selenium.go_back
		wait_for_load
		return ""
	end
	
	def ws_refresh args
		get_alert
		
		@selenium.refresh
		wait_for_load
		return ""
	end
	
	def ws_html args
		get_alert
		
		@selenium.get_html_source
	end
	
	def ws_click args
		get_alert
		
		xpath = args[:xpath].should_not! :be_nil
		
		set_page_unavailable
		@selenium.click("xpath=#{xpath}")
		wait_for_load				
		
		return ""
	end
	
	def ws_xpath_eval args
		get_alert
		
		xpath = args[:xpath].should_not! :be_nil
		code = args[:code].should_not! :be_nil
		
		xpath_eval xpath, code
	end
	
	# [textfield, textarea, file]	
	def ws_text args
		get_alert
		
		xpath = args[:xpath].should_not! :be_nil
		begin
			return @selenium.get_value("xpath=#{xpath}")
		rescue Exception => e
			if e.message =~ /is it really a form field/ # This is Text not Text Input
				return xpath_eval xpath, "$this.innerHTML"
			else
				raise e
			end
		end
	end
	
	# TextField, TextArea, FileInput	
	def ws_type args
		get_alert
		
		xpath, text = args[:xpath].should_not!(:be_nil), args[:text].should_not!(:be_nil)
		@selenium.type("xpath=#{xpath}", text)
		wait_for_load
		return ""
	end
	
	# radiobutton, checkbox	
	def ws_checked args
		get_alert
		
		xpath = args[:xpath].should_not! :be_nil						
		return @selenium.is_checked("xpath=#{xpath}") ? "true" : "false"
	end
	
	# radiobutton, checkbox	
	def ws_check args
		get_alert
		
		xpath = args[:xpath].should_not!(:be_nil)
		checked = args[:checked].should_not!(:be_nil) == "true"
		
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
		wait_for_load
		return ""
	end	
	
	# Select, Multiselect	
	def ws_select args
		get_alert
		
		xpath = args[:xpath].should_not!(:be_nil)
		options = args[:options].should_not!(:be_nil).split("\n")
		
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
		wait_for_load
		return ""
	end
	
	# Select, Multiselect	
	def ws_selection args
		get_alert		
		
		xpath = args[:xpath].should_not!(:be_nil)
		result = begin
			@selenium.get_selected_values("xpath=#{xpath}")			
		rescue RuntimeError => e
			if e.message =~ /No option selected/
				[]
			else
				raise e
			end
		end
		return result.join("\n")
	end					
	
	def ws_get_alert args
		result = get_alert
		result ? result : "__nil__"
	end
	
	def ws_list args
		xpath = args[:xpath].should_not! :be_nil		
		list xpath				
	end
	
	def ws_eval args
		code = args[:code].should_not! :be_nil
		return selenium_eval(code)		
	end
	
	def alive?
		clear			
		begin
			wait_for{(list("//div") =~ /DIV|div/) != nil}
			return true
		rescue TimeoutError
			return false
		end		
	end
	
	def clear		
		get_alert
		
		@selenium.delete_all_visible_cookies
		@selenium.open "http://#{CONFIG[:service_uri]}:#{CONFIG[:service_port]}/blank_page"
	end
	
	def close
		get_alert
		
		@selenium.stop
	end
	
	def to_s
		"BrowserAdapter #{CONFIG[:service_uri]}:#{CONFIG[:service_port]}"
	end
	alias_method :inspect, :to_s
	
	protected			
	def set_page_unavailable
		selenium_eval "#{PAGE_AVAILABLE} = false"
	end
	
	def selenium_eval str
		result_str = @selenium.get_eval str
		check_for_error(result_str)
		return result_str
	end
	
	def selenium_timeout
		(@config[:timeout] * 1000).round
	end
	
	def xpath_eval xpath, code		
		selenium_eval %{UIDriver.xpath_eval(window.document, "#{xpath}", "#{code}")}				
	end
	
	def get_alert
		@selenium.get_alert rescue nil
	end
	
	def wait_for &b
		UIDriver::Utils.wait_for(@config[:timeout], @config[:retry_timeout], &b)
	end
	
	def list xpath
		selenium_eval %{UIDriver.list(window.document, "#{xpath}")}
	end
	
	def check_for_error str
		raise str.gsub("ERROR_MESSAGE", "") if str =~ /^ERROR_MESSAGE/
	end
	
	def wait_for_load		
		return unless @config[:auto_wait]
		wait_for{selenium_eval(PAGE_AVAILABLE) == "true"}		
	end				
	
	synchronize_all
end