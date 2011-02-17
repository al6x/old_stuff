require 'UIDriver/Client/require'
require 'spec'

WEB_URI = "localhost:8080/ui"
REST_URI = "localhost:8080/rest"

require 'ActivePoint/Adapters/Rest/client'

module APSpecMix	
	def rest_client
		@rest_client ||= ActivePoint::Adapters::Rest::Client.new REST_URI, "admin", ""
	end
	
	def login! *args
		should_have :link, "Login"
		login *args
	end
	
	def logout!
		should_have :link, "Logout"
		logout
	end
	
	def login args = {}
		args = {:name => "admin", :password => "", :browser => self}.merge args
		b = args[:browser]
		return if b.has?(:link, "Logout")
		b.click "Login"
		b.should_have "Login"
		b.attribute("Name:").type args[:name]
		b.attribute("Password:").type args[:password]
		b.click "Ok"
		b.should_have "Logout"
	end
	
	def logout args = {}
		b = {:browser => self}.merge(args)[:browser]
		return if b.has? :link, "Login"
		b.click "Logout"
		b.should_have "Login"
	end	
	
	def disable_security
		rest_client["Core/Development"].eval "ActivePoint::CONFIG[:disable_security] = true"
		#		begin
		#			b = Browser.new WEB_URI
		#			b.go ""
		#			login :browser => b
		#			b.go "Core/Development"
		#			b.attribute_bottom_of("Development").type \
		#		%{::ActivePoint::CONFIG[:disable_security] = true}
		#			b.click "Eval"
		#		ensure
		#			b.close
		#		end
	end
	
	def enable_security
		rest_client["Core/Development"].eval "ActivePoint::CONFIG[:disable_security] = false"
		#		begin
		#			b = Browser.new WEB_URI
		#			b.go ""
		#			login :browser => b
		#			b.go "Core/Development"
		#			b.attribute_bottom_of("Development").type \
		#		%{::ActivePoint::CONFIG[:disable_security] = false}
		#			b.click "Eval"
		#		ensure
		#			b.close
		#		end
	end
	
	
	def set_uidrive_mode value
		value.should! :be_a, [TrueClass, FalseClass]
		rest_client.eval "WGUI::CONFIG[:uidriver_mode] = #{value}"
	end
	
	def title_should_be 
		
		
		
		
		
		
		""
	end
	
	def reset_data!
		rest_client.eval "ActivePoint::Engine.reset_data!"
	end
end

Spec::Runner.configure do |config|	
	config.include RSpecBrowserExtension, APSpecMix
	
	config.before :all do
		reset_data!
		disable_security
		set_uidrive_mode true
	end
	
	config.after :all do
		set_uidrive_mode false
	end
	
	config.before :each do
		self.browser = Browser.new WEB_URI
	end
	
	config.after :each do
		browser.close
	end
end