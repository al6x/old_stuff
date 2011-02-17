class Config
	extend Configurator
	
	depends_on Core, Users
	
	initialize_data do
		R.transaction(Transaction.new){
			core = R.by_id "Core"
			security = Security::Model::Security.new("Security", "Security")
			core.plugins << security
			
			# Permissions
			security.permissions = [
			"view",
			"edit",
			"create",
			"delete",
			"manage",		
			]
			
			# Roles
			security.roles << Model::Role.new("Viewer").set!(:permissions => ["view"].to_set)
			security.roles << Model::Role.new("Editor").set!(:permissions => ["view", "edit", "create", "delete"].to_set)
			security.roles << Model::Role.new("Manager").set!(:permissions => ["manage", "view", "edit", "create", "delete"].to_set)
			
			# Policies
		}.commit
	end	
end