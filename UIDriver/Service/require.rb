require "RubyExt/require"
require "facets/daemonize"

module UIDriver
	module Service
		CONFIG = Hash.new{|hash, key| raise "There is no setting '#{key}'!"}
		CONFIG.merge! Service["config.yaml"]	
	end
end