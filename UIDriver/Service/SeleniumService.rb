class SeleniumService		
	include Singleton
	inherit Log		
	
	def initialize
		super
		
		@pool, @rented = [], {}
		@sync = Monitor.new
		
		Thread.new do
			while true do
				begin
					sleep CONFIG[:check_expired_browsers_timeout]
					close_expired
				rescue Exception => e
					log.error e
				end
			end
		end				
	end				
	
	def ws_configure args
		args.keys.every.should! :be_in, [:method_name, :browsers_pool_size, :max_browsers, 
		:check_expired_browsers_timeout].collect{|m| m.to_s}
		
		CONFIG[:browsers_pool_size] = args[:browsers_pool_size].to_i.should!(:>, 0) if args[:browsers_pool_size]
		CONFIG[:max_browsers] = args[:max_browsers].to_i.should!(:>, 0) if args[:max_browsers]
		if args[:check_expired_browsers_timeout]
			CONFIG[:check_expired_browsers_timeout] = args[:check_expired_browsers_timeout].to_f.should!(:>, 0)
		end
		
		return ""
	end
	
	def get_browser id
		browser = @sync.synchronize do 
			raise "Invalid Browser ID '#{id}'!" unless @rented.include? id
			@rented[id]
		end
		browser.touch!
		return browser
	end
	
	def ws_rent_browser args
		begin
			browser = @sync.synchronize do
				raise "No avaliable Browsers!" unless @rented.size < CONFIG[:max_browsers]
				@pool.pop 
			end
			
			browser ||= BrowserAdapter.new	
			browser.configure args
			
			unless browser.alive?
				browser.close rescue{}
				browser = BrowserAdapter.new
				browser.configure args
				raise "Internal Error (Can't create Browser)!" unless browser.alive?
			end
			
			browser.touch!		
			id = generate_id
			
			success = @sync.synchronize do 
				if @rented.size < CONFIG[:max_browsers] # Double check becouse there can be created another in another thread!
					@rented[id] = browser
					true
				else
					false
				end			
			end		
			unless success
				browser.close rescue{}
				raise "No avaliable Browsers!"
			end
			return id
		rescue Exception => e
			browser.close rescue{}
			raise e
		end
	end
	
	def ws_release_all args
		keys = @sync.synchronize{@rented.keys.clone}
		keys.each{|id| release_browser id}
		return ""
	end
	
	def ws_release_browser args
		release_browser args[:browser_id]		
		return ""
	end		
	
	def to_s
		"SeleniumService #{CONFIG[:service_uri]}:#{CONFIG[:service_port]}"
	end
	
	def self.create_selenium_dirver
		Selenium::SeleniumDriver.new\
		"localhost", 
		CONFIG[:selenium_port], 
		CONFIG[:launcher], 
		"http://localhost", 
		CONFIG[:selenium_timeout] * 1000
	end
	
	def self.start_selenium_driver
		user_ext = File.dirname(__FILE__) + '/user-extensions.js'
		cmd = %{java -jar "#{CONFIG[:path_to_selenium_server]}" -userExtensions "#{user_ext}"}
		fork do
			Kernel.daemonize
			Kernel.exec cmd
		end
	end
	
	def self.stop_selenium_driver
		create_selenium_dirver.shut_down_selenium_server
	end		
	
	protected	
	def release_browser id
		begin
			browser = @sync.synchronize do
				return unless @rented.include? id
				@rented.delete id
			end
			
			pool_size = @sync.synchronize{@pool.size}
			if pool_size < CONFIG[:browsers_pool_size]
				if browser.alive?
					browser.clear
					success = @sync.synchronize do
						if @pool.size < CONFIG[:browsers_pool_size] # Double check becouse there can be created another in another thread!
							@pool << browser
							true
						else
							false
						end
					end				
					browser.close rescue{} unless success
				else
					browser.close rescue{}
				end
			else 
				browser.close
			end
		rescue Exception => e
			browser.close rescue{}
			raise e
		end
	end
	
	def close_expired
		expired = []
		@sync.synchronize do
			@rented.each{|id, browser| expired << id if browser.expired?}
		end
		expired.each{|id| release_browser id }
	end	
	
	def generate_id
		rand(1_000_000_000).to_s
	end				
end

SeleniumService.instance