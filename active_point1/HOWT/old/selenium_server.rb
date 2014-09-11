module HOWT		
	class SeleniumServer
		private :initialize
		
		def self.instance
			@@self ||= SeleniumServer.new			
		end
		
		def start
#			return if @started
#			cmd = %{java -jar "#{CONFIG[:path_to_selenium_server]}" \
#-userExtensions "#{File.join('howt', 'user-extensions.js')}"}
#			unless Kernel.system cmd
#				raise "Can't start Selenium Server RC!"
#			end

			@started = true
			sleep 2
		end
		
		def stop
			@started = false
			sleep 2
		end
	end
end
