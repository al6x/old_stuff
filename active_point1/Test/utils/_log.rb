require 'log4r'
require 'log4r/configurator'

# Load configuration file
log_dir = "logs"
Log4r::Configurator['logpath'] = log_dir
Dir.mkdir log_dir unless File.exists? log_dir
begin	
	Log4r::Configurator.load_xml_file('config/log4r.xml')
rescue Errno::ENOENT
end

# Log module for including in other classes
module Log		
	def self.included(a_class)
		a_class.extend(Log)
	end	
		
	def self.log a_class = Log.name
		begin
			log = Log4r::Logger.get a_class
		rescue Exception
			log = Log4r::Logger.new a_class
		end		   
		return log
	end
		    
	def log
		unless @log
			@log = Log.log self.kind_of?(Class) ? self.name : self.class.name
		end		
		@log
	end
	
	def self.info *s; Log.log.info(*s) end
	def self.warn *s; Log.log.warn(*s) end
	def self.error *s; Log.log.error(*s) end
	def self.debug *s; Log.log.debug(*s) end
end