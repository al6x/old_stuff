# Set-up WebTester
require 'WGUI/require'
require 'HOWT/require'
require 'spec'

WGUI::Utils::TestServer
include HOWT::BrowserHelper

# Start/Stop services
Spec::Runner.configure do |config|
	config.before(:all) do
#		sleep 5
		start_webserver
		begin
#			require 'win32/sound'
#			Win32::Sound.beep(2000, 100)
		rescue
        end
	end

	config.after(:all) do
		stop_webserver
		close
		begin
#			require 'win32/sound'
#			Win32::Sound.beep(1000, 300)
		rescue
        end
	end
end
