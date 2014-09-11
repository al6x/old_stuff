module CMessaging		
	#	def send_message message
	#		ScopeManager.synchronize{Scope[MQ::MessageQueue]}.send_message message
	#	end
	
	def send_message message
		Scope[MQ::MessageQueue].send_message message
	end
	
	def listen_to message, method = :on_message
		Scope[MQ::MessageQueue].listen_to self.class, message, method
	end
	
	def detach_from message
		Scope[MQ::MessageQueue].detach_from self.class, message
	end
end