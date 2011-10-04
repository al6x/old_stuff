class Services
	inherit RubyExt::Synchronizer
	
	def initialize
		super
		@services = Hash.new{|h, k| raise "No #{k} Service!"}
	end
	
	def [] name
		@services[name]
	end
	
	def []= name, service
		service.should_not! :be_nil
		@services[name] = service
	end
	
	def include? name
		@services.include? name
	end
	
	synchronize_all
end