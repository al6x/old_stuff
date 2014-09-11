class Services
	extend Managed
	scope :application
	
	include MonitorMixin
	
	def initialize
		super
		@services = Hash.new{should! :be_never_called}
	end
	
	def [] name
		synchronize{@services[name]}
	end
	
	def []= name, service
		synchronize{@services[name] = service}
	end
	
	def include? name
		synchronize{@services.include? name}
	end
end