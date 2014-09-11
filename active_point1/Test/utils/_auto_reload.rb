require 'utils/log'
require 'utils/observable'

module ::Utils
	class AutoReload
		include Log
		extend ::Utils::Observable
		
		def self.start interval = 2, basedir = "."
			return if @thread
			
			@thread = Thread.new do
				times = Hash.new
				Dir.glob("#{basedir}/**/**").each do |f|
					times[f] = File.mtime(f)
				end
				
				while true
					sleep interval
					Dir.glob("#{basedir}/**/**").each do |f|
						old_time = times[f]
						if old_time == nil or old_time != File.mtime(f)
							notify_observers File.expand_path(f)
							times[f] = File.mtime(f)
						end
					end
				end
			end				
        end
		
		def self.stop
			return unless @thread
			@thread.kill
			@thread = nil
        end
    end
end