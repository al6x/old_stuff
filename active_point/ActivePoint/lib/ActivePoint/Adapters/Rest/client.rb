require 'rest_client'
require 'json'
require 'ActivePoint/Adapters/Rest/specification'

module ActivePoint
	module Adapters
		module Rest
			
			class Client
				include Specification::Client
				
				attr_reader :base_uri
				
				def initialize base_uri, name = "", password = ""
					@base_uri, @name, @password = base_uri, name, password
				end
				
				def [] path
					Callback.new self, path
				end
				
				def execute uri, method, *args
					translate @name, @password, uri, method, *args		
				end
				
				def eval code
					translate @name, @password, "__eval__", "", code
				end
			end	
			
			class Callback
				[:type, :select, :eval].each{|m| undef_method m}
				
				def initialize client, uri
					@client, @uri = client, uri
				end
				
				def method_missing m, *args
					@client.execute @uri, m, *args
				end
			end
			
		end
	end
end