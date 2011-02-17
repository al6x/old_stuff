class Listener	
	def after_commit entities
		# Notify different Observers
		entities.each do |e| 
			Scope.notify_observers e.entity_id
		end				
	end
end