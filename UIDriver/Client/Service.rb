class Service
	class << self
		def release_all
			service.release_all
		end
		
		def configure args
			service.configure args
		end
		
		protected 
		def service
			service = "http://#{CONFIG[:service_uri]}:#{CONFIG[:service_port]}"
			return RestClient::Resource.new "#{service}/service"
		end
	end
end