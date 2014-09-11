class Listener	
	def after_commit entities
		entities.each{|e| Scope.notify_observers e.om_id}
	end
end