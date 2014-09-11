class Config
	extend Configurator
	
	depends_on Services::WebServer
	
	startup do		
		require 'sinatra/base'
		require "#{File.dirname __FILE__}/specification"
		
		Rest::REST_NAME = "Rest"
		::RestController = ActivePoint::Adapters::Rest::RestController
		
		Scope[:services][:webserver].map CONFIG[:rest_prefix], RestAdapter
	end		
end