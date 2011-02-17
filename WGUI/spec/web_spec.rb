# Set-up WebTester
require 'WGUI/require'
require 'UIDriver/Client/require'
require 'spec'

WGUI::Utils::TestServer

# Start/Stop services
Spec::Runner.configure do |config|	
	config.include RSpecBrowserExtension
	
	config.before :all do		
		start_webserver
	end

	config.after :all do
		stop_webserver				
	end
	
	config.before :each do
		self.browser = Browser.new
	end
	
	config.after :each do
		browser.close
	end
end
