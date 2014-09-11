class WebServer
	extend Configurator
	
	def initialize
		@map = {"/" => redirect_to_default_object}
	end
	
	def map path, application
		@map[path] = application
	end		
	
	def activate
		app = Rack::URLMap.new(@map)				
		#		app = Rack::Lint.new app if $debug TODO Stub		
		app = Rack::Handler::Mongrel.new app
		server = Mongrel::HttpServer.new('0.0.0.0', CONFIG[:port].should_not!(:be_nil))
		server.register('/', app)		
		@webserver = server.run
	end
	
	def join											
		@webserver.join				
	end
	
	startup do
		Scope[:services][:webserver] = WebServer.new
	end
	
	protected
	def redirect_to_default_object						
		lambda do |env| 
			head = {
				"location" => "#{CONFIG[:wgui_prefix]}/#{CONFIG[:default_object]}", 
				"Content-Type" => "text/html"
			}
			[301, head, []]
		end
	end						
end