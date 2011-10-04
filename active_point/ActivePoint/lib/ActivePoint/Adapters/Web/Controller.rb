module Controller
	inherit Services::Security::SecureMethods
	
	attr_reader :view		
	
	def show; end # Esle it will throw "Not defined" error
	secure :show => :view
	
	def secure_method_call method, *args	
		unless self.class.can_execute_method? C.user, C.object, method, *args		
			C.messages.error ActivePoint::Services::Security.to_l("You hasn't permission!")
		else
			send method, *args
		end		
	end				
end