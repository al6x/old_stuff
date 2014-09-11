class Runner
	def self.start app_class, root_wportlet_id = nil
		app = WGUI::Engine::BrigeServlet.new app_class, "/ui", root_wportlet_id
		#		app = Rack::Session::Pool.new app 
		#	app = Rack::ShowExceptions.new app
		#		app = Rack::Lint.new app if $debug
#		app = Rack::URLMap.new "/ui" => app, "/ws" => lambda{|env| [200, {"Content-Type" => "text/plain",}, ["WS"]]}
		app = Rack::URLMap.new "/ui" => app
		app = Rack::Handler::Mongrel.new app
		
		server = Mongrel::HttpServer.new('0.0.0.0', CONFIG[:port])
		server.register('/', app)
		@webserver = server.run
	end
	
	def self.join
		@webserver.join
	end
	
	def self.stop
		@webserver.raise Mongrel::StopServer
	end
end
