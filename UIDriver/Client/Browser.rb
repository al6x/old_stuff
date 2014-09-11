class Browser		
	def initialize base_uri = "", args = {}
		@base_uri = base_uri.should! :be_a, String
		
		service = "http://#{CONFIG[:service_uri]}:#{CONFIG[:service_port]}"
		@s = RestClient::Resource.new "#{service}/service"
		
		params_names = [:timeout, :speed, :browser_expires, :retry_timeout, :auto_wait]
		args.keys.every.should! :be_in, params_names		
		params = {}
		params_names.each do |name|
			params[name] = (args[name] || CONFIG[name]).should_not! :be_nil
		end
		
		@browser_id = @s.rent_browser params		
		@b = RestClient::Resource.new "#{service}/browser/#{@browser_id}"			
		
		@filters = Filters.new self
		@queries = Queries.new self
	end		
	
	def configure args
		@b.configure args
	end
	
	def base= url
		url.should! :be_a, String
		@base_uri = url
	end
	
	def close;
		@s.release_browser :browser_id => @browser_id
	end
	
	def go url, params = nil
		url.should! :be_a, String
		url = "/" + url unless url.empty? or url =~ /^\?/
		url = @base_uri + url	
		go_absolute url, params
	end
	
	def go_absolute url, params = nil		
		url.should! :be_a, String
		
		if params
			params.should! :be_a, Hash
			url += "?" + params.to_a.collect{|k, v| "#{k}=#{v}"}.join("&")
		end
		begin
			@b.go :url => url 
		rescue Exception => e
			if e.message =~ /Timed out/
				raise_without_self "URL '#{url}' is not avaliable!", UIDriver
			else
				raise e
			end
		end
	end
	
	def go_back
		@b.go_back
	end
	
#	def break
#		@b.break
#	end
	
	def refresh
		@b.refresh
	end
	
	def uri
		@b.uri
	end
	
	def html
		@b.html
	end
	
	def filter filter_name, list, *args
		filter_name.should! :be_a, Symbol
		list.should! :be_a, ResultSet
		
		@filters.send filter_name, list, *args		
	end
	
	def list query, *args
		query.should! :be_a, [String, Symbol]
		xpath = if query.is_a?(String) and args.size == 0
			query
		else			
			@queries.send query, *args			
		end		
		xpath_list xpath
	end
	
	def single *args
		rs = list *args
		if rs.size > 1
			raise "Found more than one Element!" 
		elsif rs.size == 0
			raise "No Elements!" 
		end
		return rs
	end
	
	def count *args
		list(*args).size
	end
	
	def has? *args
		list(*args).size > 0
	end
	
	def inverse_filter filter_name, list, *args
		result = filter filter_name, list, *args
		rs = Browser::ResultSet.new self
		rs.replace list.find_all{|pos| !result.include?(pos)}
		return rs
	end
	
	def xpath_list xpath
		result_str = @b.list :xpath => xpath
		
		result = ResultSet.new self
		result_str.split("\n").each do |line|
			pair = line.split(" : ")
			pair.size.should! :==, 2
			xpath = pair[0].should_not! :be_nil 
			position_str = pair[1].should_not! :be_nil
			
			positions = position_str.split(",").collect{|s| s.to_i}
			positions.size.should! :==, 4
			result << Position.new(xpath, positions)
		end
		return result
	end				
	
	def eval code
		code.should! :be_a, String
		@b.eval :code => code
	end
	
	def wait_for timeout = CONFIG[:timeout].to_f, &b
		UIDriver::Utils.wait_for timeout, CONFIG[:retry_timeout].to_f, &b
	end
	
	def xpath_eval xpath, code
		xpath.should! :be_a, String
		code.should! :be_a, String
		@b.xpath_eval :xpath => xpath, :code => code
	end
	
	def xpath_click xpath
		xpath.should! :be_a, String
		@b.click :xpath => xpath
	end
	
	def xpath_text xpath
		xpath.should! :be_a, String
		@b.text :xpath => xpath
	end
	
	def xpath_type xpath, text
		xpath.should! :be_a, String
		text.should! :be_a, String
		@b.type :xpath => xpath, :text => text
	end
	
	def xpath_checked? xpath
		xpath.should! :be_a, String
		@b.checked(:xpath => xpath) == "true" ? true : false
	end
	
	def xpath_check xpath, checked = true
		xpath.should! :be_a, String
		checked.should! :be_a, [TrueClass, FalseClass]
		@b.check :xpath => xpath, :checked => (checked ? "true" : "false")
	end
	
	# select("a"); select "a", "b"; select ["a", "b"]
	def xpath_select xpath, *options
		xpath.should! :be_a, String
		
		options = if options.size == 1
			if options[0].is_a? String
				options
			else
				options.should! :be_a, Array
				options[0]
			end			
		else
			options
		end
		
		@b.select :xpath => xpath, :options => options.join("\n")
	end
	
	def xpath_selection xpath
		xpath.should! :be_a, String
		result = @b.selection :xpath => xpath
		result.split("\n")
	end
	
	def get_alert 
		result = @b.get_alert
		result == "__nil__" ? nil : result
	end
	
	def to_s
		"Browser #{@browser_id}"
	end
	alias_method :inspect, :to_s	
end