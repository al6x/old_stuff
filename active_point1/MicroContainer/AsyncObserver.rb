class AsyncObserver
	extend Managed
	include MonitorMixin
	scope :application				
	
	class SessionObservers
		attr_reader :registered, :to_be_processed
		
		def initialize
			@registered, @to_be_processed = [], BlockedArray.new			
		end
	end
	
	#	class ListenerDefinition
	#		attr_reader :message, :observer
	#		
	#		def initialize message, observer
	#			@message, @observer = message, observer
	#		end
	#	end
	
	class ObserverDefinition
		def initialize message, observer, method, session_id
			@message, @observer, @method, @session_id = message, observer, method, session_id
		end
		
		attr_accessor :message, :observer, :method, :session_id		
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
	end
	
	def notify_observers message
#		where?
		threads_to_wakeup = nil
		synchronize do
			msg_observers = @messages[message]
			return unless msg_observers
			
			threads_to_wakeup = Set.new
			msg_observers.each do |odef|			
				session_observers = @sessions[odef.session_id]
				session_observers.should_not! :be_nil
				session_observers.to_be_processed.add odef
				threads_to_wakeup << session_observers.to_be_processed
			end								
		end
		threads_to_wakeup.each{|blocked_array| blocked_array.signal} if threads_to_wakeup
	end
	
	def add_observer message, observer, method, sid
		synchronize do
			odef = ObserverDefinition.new message, observer, method, sid
			# Insert into messages
			msg_observers = @messages[message] ||= []			
			the_same = msg_observers.find do |odef2| 
				odef2.observer == observer and odef2.method == method and odef2.session_id == sid
			end
			
			unless the_same
				msg_observers << odef
				
				# Insert into sessions
				session_observers = @sessions[sid] ||= SessionObservers.new
				session_observers.registered << odef
			end
		end
	end
	
	def delete_observer message, observer, sid
		synchronize do			
			msg_observers = @messages[message]
			return unless msg_observers			
			
			msg_observers.each do |odef| 
				if odef.observer == observer
					# Delete from messages
					msg_observers.delete odef
					
					# Delete from sessions
					session_observers = @sessions[odef.session_id]					
					session_observers.should_not! :be_nil
					session_observers.registered.delete_if do |odef2|
						message == odef2.message and observer == odef2.observer
					end
				end
			end
			@messages.delete message if msg_observers.size == 0 				
		end
	end
	
	def delete_observers sid
		synchronize do
			# Delete from sessions
			session_observers = @sessions.delete sid
			if session_observers
				# Delete from messages
				session_observers.registered.each do |odef|
					msg_observers = @messages[odef.message]
					msg_observers.should_not! :be_nil
					msg_observers.delete_if do |odef2| 
						odef2.observer == odef.observer and odef2.session_id == sid
					end
					@messages.delete odef.message if msg_observers.size == 0
				end
			end
		end
	end
	
	# Thread blocking method
	def observers_for_session sid
		session_observers = synchronize do
			session_observers = @sessions[sid] ||= SessionObservers.new
		end
		return session_observers.to_be_processed.get_array # :get_array blocks Thread
	end
end
