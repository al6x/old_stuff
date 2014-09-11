class SessionManager
	include MonitorMixin
	attr_accessor :observer_thread
	attr_accessor :active, :last_accessed_time	
end