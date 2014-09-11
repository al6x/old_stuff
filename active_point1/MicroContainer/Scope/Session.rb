class Session < Hash
	attr_reader :session_id
	
	def initialize session_id
		super()
		@session_id = session_id
		@custom = Hash.new
	end
	
	def get identifier, scope; 
		custom = scope_get(scope).first
		custom[identifier]
	end
	
	def set identifier, scope, value; 
		custom = scope_get(scope).first
		custom[identifier] = value
	end
	
	def scope_begin scope		
		@custom[scope] = [{}]
	end
	
	def scope_end scope
		@custom.delete scope
	end
	
	def active? scope
		@custom.include? scope
	end
	
	def continuation_begin scope
		custom = scope_get(scope)
		custom.unshift({})
	end
	
	def continuation_end scope
		custom = scope_get(scope)
		custom.shift
	end
	
	def custom_scope_get scope_name
		scope_get(scope_name).first
	end
	
	def custom_scope_set scope_name, scope
		scope_get(scope_name)[0] = scope
	end
	
	protected
	def scope_get scope_name
		scope = @custom[scope_name]
		raise_without_self "Scope '#{scope_name}' hasn't been started!", MicroContainer unless scope
		scope
	end
	
#	def scope_set scope_name, scope
#		raise_without_self "Scope '#{scope_name}' hasn't been started!", MicroContainer unless @custom.include? scope_name
#		@custom[scope_name] = scope						
#	end
end
