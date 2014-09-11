module Synchronizer
	include MonitorMixin
	
	module ClassMethods
		def synchronize *methods
			methods.each do |name|			
				alias_method :"sync_#{name}", name
				script = "\
def #{name} *p, &b
	synchronize{sync_#{name} *p, &b}
end"
				class_eval script, __FILE__, __LINE__
			end
		end
		
		def synchronized_all
			p "Synchronizer Not implemented"
		end
	end
end