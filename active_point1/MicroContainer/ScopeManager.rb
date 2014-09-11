class ScopeManager
	extend MonitorMixin
	
	@session_managers = {}
	SESSION_MANAGER = :MC_SessionManager
	class << self
		def include? session_id
			@session_managers.include? session_id
		end  	
		
		def activate_thread session_id, synchronize = true, create_new = true, &block
			session, session_manager = nil, nil
			begin				
				synchronize do
					session_manager = @session_managers[session_id]
					return unless session_manager or create_new
					unless session_manager
						session_manager = Scope::SessionManager.new
						@session_managers[session_id] = session_manager
					end
					session_manager.last_accessed_time = Time.new
					session_manager.active = true
					
					Thread.current[SESSION_MANAGER].should! :be_nil
					Thread.current[SESSION_MANAGER] = session_manager
					
					session = Scope._activate_thread session_id
				end
				
				if synchronize
					session_manager.synchronize do
						block.call
					end
				else
					block.call
				end
			ensure
				synchronize do
					begin
						Scope._deactivate_thread
					ensure
						Thread.current[SESSION_MANAGER] = nil
						session_manager.active = false if session_manager
					end
				end
			end
		end
		
		def delete_sessions_older_than sec			
			synchronize do
				current = Time.new
				to_delete = []
				@session_managers.each do |sid, sm|
					if !sm.active and current - sm.last_accessed_time > sec						
						sm.observer_thread.kill if sm.observer_thread
						to_delete << sid
						Scope._delete_session sid 
						Scope[AsyncObserver].delete_observers sid
					end
				end
				to_delete.each{|sid| @session_managers.delete sid}
			end
		end
		
		def clear
			synchronize do
				@session_managers.clear
				Scope._clear
			end
		end
		
		#		def session_alive? session_id
		#			synchronize do
		#				@session_managers.include? session_id
		#            end
		#        end
	end
	
	# Should NOT be used inside active session
	# Block can be processed inside active session
	def self.process_async_observers_for_session session_id, kill_previous_thread = true, &block
		Thread.current[SESSION_MANAGER].should! :be_nil
		
		session_manager = nil
		synchronize do
			session_manager = @session_managers[session_id]
		end
		
		unless session_manager
			raise_without_self InvalidSessionError, "There is no alive session with session_id = '#{session_id}'!",
			MicroContainer
		end
		
		# Kill previous thread (needed for AJAX COMET)
		if kill_previous_thread
			session_manager.observer_thread.kill if session_manager.observer_thread
		end
		
		session_manager.observer_thread = Thread.current # For session timeout remove.
		
		# Waiting for messages
		as_obs = synchronize{Scope[AsyncObserver]}
		
		observers = as_obs.observers_for_session(session_id)
		
		# Processing messages
		activate_thread session_id do
			observers.each do |odef|
				begin
					odef.observer.send odef.method
				rescue ArgumentError => e
					warn "ArgumentError for #{Scope[listener.component]}.#{listener.method}"
					raise e
				end
			end
			
			block.call if block
		end
	end
end