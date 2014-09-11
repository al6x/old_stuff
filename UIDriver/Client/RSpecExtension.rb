module RSpecExtension
	class HaveExtension
		def initialize(browser, args)
			@browser, @expected = browser, args
		end
		
		def matches?(target)
			browser = if target and target.respond_to? :browser
				target.browser
			else
				@browser
			end
			
			args = if @expected.size == 1
				[:text, *@expected]
			else
				@expected
			end
			browser.has? *args
		end
		
		def failure_message
			%{expected #has_text?("#{@expected}") to return true, got false}
		end
		
		def negative_failure_message
      %{expected #has_text?("#{@expected}") to return false, got true}
		end
	end
	
	def have *args
		browser = self.respond_to?(:browser) ? self.browser : nil
		HaveExtension.new browser, args
	end					
	
	def self.have browser, *args
		HaveExtension.new browser, args
	end
	
	
	attr_accessor :browser
	
	BROWSER_METHODS = HandyBrowser.instance_methods.collect{|m| m.to_sym}.to_set
	[:close].each{|m| BROWSER_METHODS.delete m}
	
	#(Browser.instance_methods(false) + HandyBrowser.instance_methods(false))
	#	[:go].each do |m|
	#		script = %{\
	#def #{m} *args, &b
	#	raise "Browser not initialized!" unless browser		
	#	browser.send :#{m}, *args, &b
	#end}
	#		
	#		eval script, binding, __FILE__, __LINE__
	#	end
	def method_missing m, *args, &b
		if BROWSER_METHODS.include? m
			unless browser						
				raise "Browser not initialized!"
			end
			browser.send m, *args, &b
		else
			super
		end
	end
	
	def respond_to? m, priv = false		
		if BROWSER_METHODS.include? m
			raise "Browser not initialized!" unless browser		
			true
		else
			super
		end
	end
	
	#	def should_have *args, &b
	#		return if args.empty?
	#		raise "Browser not initialized!" unless browser		
	#		browser.should_have *args, &b
	#	end
	#	
	#	def should_not_have *args, &b
	#		return if args.empty?
	#		raise "Browser not initialized!" unless browser		
	#		browser.should_have *args, &b
	#	end
end