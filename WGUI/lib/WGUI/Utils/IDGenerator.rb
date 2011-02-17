if $debug
	class IDGenerator
		include MonitorMixin
		extend Managed
		scope :application
		
		def initialize;
			super
			@counters = Hash.new(0) 
		end
		
		def generate class_name
			synchronize do
				name = class_name.split('::').last
				return "#{name}_#{@counters[name] += 1}"
			end
		end
	end
else
	class IDGenerator
		extend Managed
		scope :session
		
		def initialize;
			super
			@counter = 0 
		end
		
		def generate class_name
			return "cid_#{@counter += 1}"
		end
	end
end