# Process only the Application Scope Components
class AppScopeExecutor		
	include Log
	
	def initialize message_queue				
		Thread.new do
			while true
				# Waiting for messages
				listeners = message_queue.messages_for_application
				
				# Processing
				listeners.each do |listener|
					begin						
						ScopeManager.synchronize{Scope[listener.component]}.send listener.method						
					rescue Exception => e
						log.error e
					end
				end
			end			
		end
	end
end