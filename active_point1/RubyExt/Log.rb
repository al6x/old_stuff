require 'log4r'
require 'log4r/configurator'

module Log
	@loggers = Hash.new do |hash, klass|
		# Such complex initialization because I don't know how it exactly work.
		# For example: Log.new for WGUI::SomeClass will works, but Log.new for WGUI will not.
		logger = begin
			Log4r::Logger.get(klass.name) 				
		rescue 
			Log4r::Logger.new(klass.name) rescue Log4r::Logger.get("Default")
		end
		hash[klass] = logger
	end
	
	module ClassMethods
		def log		
			Log.loggers[(self.class == Class or self.class == Module) ? self : self.class]
		end						
	end
	
	def log
		Log.loggers[(self.class == Class or self.class == Module) ? self : self.class]
	end				
		
	class << self
		attr_reader :loggers
		
		def info *s
			log.info *s
		end
		
		def error *s
			log.error *s
		end
		
		def warn *s
			log.warn *s
		end
		
		def log
			Log.loggers[Log]
		end				
	end
	#	configure %{\
	#<log4r_config>
	#	<pre_config>
	#		<global level="ALL"/>
	#	</pre_config>
	#
	#	<outputter type="StderrOutputter" name="default" level="ALL"/>
	#	<logger name="Default" level="ALL" outputters="default"/>
	#</log4r_config>}
end
Log4r::Configurator.load_xml_string(Log["config.xml"]) 