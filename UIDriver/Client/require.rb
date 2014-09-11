require "RubyExt/require"

require 'rest_client'
require "#{File.dirname __FILE__}/rest_client"

module UIDriver
	module Client
		CONFIG = Hash.new{|hash, key| raise "There is no setting '#{key}'!"}
		CONFIG.merge! Client["config.yaml"]				
	end
end

RSpecBrowserExtension = UIDriver::Client::RSpecExtension
Browser = UIDriver::Client::HandyBrowser