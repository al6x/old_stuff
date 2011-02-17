class MessageQueue
	extend Managed
	include MonitorMixin
	scope :application				
	
	class RPPair
		attr_reader :registered, :to_be_processed
		
		def initialize
			@registered, @to_be_processed = [], BlockedArray.new			
		end
	end
	
	class MCPair
		attr_reader :message, :component
		
		def initialize message, component
			@message, @component = message, component
		end
	end
	
	def initialize
		super
		# message => 
		#	[Listener] - listeners registered for this topic.
		#
		@messages = {}
		
		# session_id => 
		#	[list of components registered for this session]
		#	[list of messages to be processed for this session]
		@sessions = {}
		@messages_for_application = BlockedArray.new
		
		AppScopeExecutor.new self
	end
	
	def send_message message
		signal = nil
		synchronize do
			listeners = @messages[message]
			if listeners			
				signal = Set.new
				listeners.each do |listener|
					if listener.session_id
						rp_pair = @sessions[listener.session_id]
						rp_pair.to_be_processed.add listener
						signal.add rp_pair.to_be_processed
					else
						@messages_for_application.add listener
						signal.add(@messages_for_application)
					end
				end								
			end		
		end
		signal.each{|blocked_array| blocked_array.signal} if signal
	end
	
	def listen_to component, message, method
		synchronize do
			listeners = @messages[message]			
			@messages[message] = (listeners = []) unless listeners
			
			scope, initializer = Scope.registry component
			if scope == :application # Application
				listeners << Listener.new(nil, component, method)
			elsif scope # Session or narrow one
				unless Scope._session
					raise_without_self "Component with :session or more narrow scope \
cannot be registered outside of its Session!", MicroContainer
				end
				
				listeners << Listener.new(Scope._session.session_id, component, method)
				
				# Insert into sessions
				rp_pair = @sessions[Scope._session.session_id]
				@sessions[Scope._session.session_id] = (rp_pair = RPPair.new) unless rp_pair
				rp_pair.registered << MCPair.new(message, component)
			else
				raise_without_self "Component Scope is not defined!", MicroContainer
			end
		end
	end
	
	def detach_from component, message; 
		synchronize do
			listeners = @messages[message]
			if listeners
				listeners.each do |listener| 
					if listener.component == component					
						listeners.delete listener
						
						# Delete from sessions
						if listener.session_id
							rp_pair = @sessions[listener.session_id]
							if rp_pair
								rp_pair.registered.delete_if do |mc|
									message = mc.message and component == mc.component
								end
							end
						end
					end
				end
				@messages.delete message if listeners.size == 0 				
			end
		end
	end
	
	def delete_session session_id
		# Searching by index
		synchronize do
			rp_pair = @sessions.delete session_id
			if rp_pair
				rp_pair.registered.each do |mc|
					listeners = @messages[mc.message]
					listeners.delete_if{|listener| listener.component == mc.component}
					@messages.delete mc.message if listeners.size == 0
				end
			end
		end
	end
	
	def messages_for_application
		return @messages_for_application.get_array
	end
	
	def messages_for_session session_id
		rp_pair = nil
		synchronize do
			rp_pair = @sessions[session_id]
			@sessions[session_id] = (rp_pair = RPPair.new) unless rp_pair			
		end
		return rp_pair.to_be_processed.get_array
	end
end
