# extend Managed
#	scope [:session | :thread | :instance | :application | :<custom>
#	
#	inject :attribute => Session
#	
#	inject :attribute => [:scope, :variable]
#
#
module Managed
	include Injectable
	
	def scope scope; 
		unless scope.is_a? Symbol
			raise_without_self "Scope Name shoul be a Symbol!", MicroContainer
		end
		::MicroContainer::Scope.register(self, scope){self.new}
	end
end