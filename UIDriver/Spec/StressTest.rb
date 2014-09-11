require "UIDriver/Client/require"

Browser = UIDriver::Client::Browser
Service = UIDriver::Client::Service


UIDriver::Client::CONFIG.merge!\
:timeout => "50",				
:browser_expires => "3600",				
:retry_timeout => "0.02"

Service.configure\
:browsers_pool_size => "10",
:max_browsers => "10",
:check_expired_browsers_timeout => "3600"


def general_test		
	b = Browser.new "localhost:7000"
	b.go "stress/opengoo"
	10.times{b.has?(:link, /ignacio/).should! :be_true}
	b.refresh
	b.close
end

n = 1

n.times{Browser.new}
Service.release_all

time = Time.now
n.times do
	fork{general_test}
end
Process.wait

p "All: " + (Time.now - time).to_s
