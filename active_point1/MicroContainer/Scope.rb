# Predefined scopes are: :application | :session | :thread | :instance | :"custom_name"
#
# Scopes :"custom_name" are managed by 'scope_begin' / 'scope_end' methods
# 
# :"custom_name" can't be nested (it will destroy old and start new one) and always should be explicitly started1.

class Scope			
	SESSION = :MC_Session
	THREAD = :MC_Thread		
	REGISTRY_SYNC = Monitor.new
	APPLILCATION_SYNC = Monitor.new
	
	extend Log
	
	@application, @sessions, @registry = {}, {}, {}
	@before_session, @after_session, @before_custom, @after_custom, @groups = nil, nil, {}, {}, {}
	
	class << self				                						
		def _activate_thread session_id
			Thread.current[SESSION].should! :be_nil
			
			session = @sessions[session_id]
			new_session = false
			unless session
				new_session = true
				session = Session.new session_id
				@sessions[session_id] = session
			end
			
			Thread.current[SESSION] = session
			Thread.current[THREAD] = {}
			@before_session.every.call if @before_session and new_session
			return session					
		end
		
		def _deactivate_thread       
			Thread.current[SESSION] = nil
			Thread.current[THREAD] = nil      
		end
		
		def _delete_session session_id
			@after_session.call if @after_session
			@sessions.delete session_id
		end
		
		# Should be used inside active session
		def _session
			Thread.current[SESSION]
		end
		
		# Should be used inside active session
		def begin scope
				Thread.current[SESSION].scope_begin scope
				
				before = @before_custom[scope]
				before.every.call if before
			end
			
			# Should be used inside active session
			def end scope
			after = @after_custom[scope]
			after.call if after
			
			Thread.current[SESSION].scope_end scope
		end                
		
		# Should be used inside active session
		def continuation_begin scope 
			Thread.current[SESSION].continuation_begin scope
		end
		
		# Should be used inside active session
		def continuation_end scope
			Thread.current[SESSION].continuation_end scope
		end
		
		# Should be used inside active session
		def custom_scope_get scope_name
			Thread.current[SESSION].custom_scope_get scope_name
		end
		
		def custom_scope_set scope_name, scope
			Thread.current[SESSION].custom_scope_set scope_name, scope
		end
		
		# Should be used inside active session
		
		# Should be synchronized if used outside active session
		#		def application
		#			@application
		#		end
		
		# Should be used inside active session
		#		def thread
		#			Thread.current[THREAD]
		#		end
		
		# Should be synchronized if used outside active session
		def [] identifier
			scope, initializer = nil
			REGISTRY_SYNC.synchronize do
				scope, initializer = @registry[identifier]
			end
			
			case scope
				when nil
				raise_without_self "The '#{identifier}' Name is not Managed!", MicroContainer        
				when :instance
				return initializer.call
				when :application
				APPLILCATION_SYNC.synchronize do
					o = @application[identifier]
					unless o
						o = initializer.call
						@application[identifier] = o
					end
					return o
				end
				when :thread
				thread = Thread.current[THREAD]
				o = thread[identifier]
				unless o
					o = initializer.call
					thread[identifier] = o
				end
				return o
				when :session
				session = Thread.current[SESSION]
				o = session[identifier]
				unless o
					o = initializer.call
					session[identifier] = o
				end
				return o
			else # Custom
				session = Thread.current[SESSION]
				o = session.get identifier, scope
				unless o
					o = initializer.call
					session.set identifier, scope, o
				end
				return o
			end
		end
		
		# Should be synchronized if used outside active session
		def []= identifier, value
			scope = nil
			REGISTRY_SYNC.synchronize do
				scope, initializer = @registry[identifier]
			end
			
			case scope
				when nil
				raise_without_self "The '#{identifier}' Name is not Managed!",
				MicroContainer
				when :instance
				# do nothing
				when :application
				APPLILCATION_SYNC.synchronize do
					@application[identifier] = value
				end
				when :thread
				thread = Thread.current[THREAD]
				thread[identifier] = value
				when :session 			
				session = Thread.current[SESSION]
				session[identifier] = value
			else # Custom
				session = Thread.current[SESSION]
				session.set identifier, scope, value
			end
		end
		
		def _clear
			@application, @sessions, @registry = {}, {}, {}
			@before_session, @after_session, @before_custom, @after_custom, @groups = nil, nil, {}, {}, {}
		end
		
		def register identifier, scope, &initializer
			REGISTRY_SYNC.synchronize do
				if @registry.include? identifier
					Scope.log.warn "Identifier '#{identifier}' has been redefined!"
				end
				@registry[identifier] = scope, (initializer || lambda{nil})
			end
		end
		
		def registry identifier
			REGISTRY_SYNC.synchronize do
				@registry[identifier]
			end
		end
		
		def unregister identifier
			REGISTRY_SYNC.synchronize do
				@registry.delete identifier
			end
		end
		
		# Should be used inside active session
		def active? scope
			Thread.current[SESSION].active? scope    		
		end
		
		def before scope, &block
			case scope
				when :instance, :application, :thread
				raise 'NotImplemented'
				when :session       
				@before_session ||= []
				@before_session << block
			else # Custom
				list = @before_custom[scope] ||= []
				list << block
			end
		end
		
		def after scope, &block
			case scope
				when :instance, :application, :thread
				raise 'NotImplemented'
				when :session       
				@after_session = block
			else # Custom
				@after_custom[scope] = block
			end   
		end
		
		def group name
			@groups[name] ||= ScopesGroup.new(name)
		end				
	end
end