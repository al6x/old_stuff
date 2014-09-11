module ScopeMix
	def add_observer message, observer, method
		session = Thread.current[Scope::SESSION]
		raise_without_self "Can't be called outside of Session", MicroContainer unless session
		self[AsyncObserver].add_observer message, observer, method, session.session_id
	end
	
	def delete_observer message, observer
		session = Thread.current[Scope::SESSION]
		raise_without_self "Can't be called outside of Session", MicroContainer unless session
		self[AsyncObserver].delete_observer message, observer, session.session_id
	end
	
	def delete_observers
		session = Thread.current[Scope::SESSION]
		raise_without_self "Can't be called outside of Session", MicroContainer unless session
		self[AsyncObserver].delete_observers session.session_id
	end
	
	def notify_observers message
		self[AsyncObserver].notify_observers message
	end
end
Scope.singleton_class.class_eval{include AsyncObserver::ScopeMix}