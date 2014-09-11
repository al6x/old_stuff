class Workspace < Hash
	extend Managed
	scope :session
	
	def restore_scopes_for object
		self.should! :include, object
		self[object].each{|name, scope| Scope.custom_scope_set name, scope}
	end
	
	def save_scopes_for object
		raise "not implemented"
#		Scope[Engine::Workspace][Extension.get_path(o)] = Scope.custom_scope_get(:object)
	end
end