require 'RubyExt/require'

require 'UIDriver/Service/require'

require 'sinatra/base'
require 'facets/expirable'
require 'rack'
#require 'json'
require 'cgi'

module UIDriver	
	module Service
		require CONFIG[:path_to_selenium_rb]
				
#		warn "Class Reloading enabled!"
#		RubyExt::Resource.add_observer UIDriver::Service
#		RubyExt::FileSystemProvider.start_watching		
#		
#		def self.update_resource type, klass, resource
#			return if klass.to_s =~ /Spec/
#			if type == :class
#				Cache.update :class			
#				RubyExt::ClassLoader.reload_class klass.name
#				Log.info "Class #{klass} has been reloaded!"
#			elsif type == :resource
#				Cache.update :class
#				WGUI::Utils::TemplateHelper.cache.clear
#				Log.info "Resource #{klass}['#{resource}'] has been reloaded!"
#			end
#		end
	end				
end

#RubyExt::Debug.trace_methods UIDriver::Service::SeleniumService
#RubyExt::Debug.trace_methods UIDriver::Service::BrowserAdapter
#warn "Trace Method enabled"

UIDriver::Service::SeleniumService.stop_selenium_driver rescue{}
UIDriver::Service::SeleniumService.start_selenium_driver
Kernel.at_exit{UIDriver::Service::SeleniumService.stop_selenium_driver}

app = Rack::Handler::Mongrel.new UIDriver::Service::RestWrapper
server = Mongrel::HttpServer.new('0.0.0.0', UIDriver::Service::CONFIG[:service_port])
server.register('/', app)
webserver = server.run		
webserver.join	