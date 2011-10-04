class Config
	extend Configurator
	
	depends_on Core, Users, Security
	
	initialize_data do
		R.transaction(Transaction.new){
			core = R.by_id "Core"
			
			# Development
			dev = Model::Development.new "Development", "Development"
			core.plugins << dev
			
			# Security Group
			users = R.by_id "Users"
			
			administrator = R.by_id Users::Model::User::ADMINISTRATOR
			dev_group = Users::Model::Group.new "Developers"
			dev_group.add_user administrator
			users.groups << dev_group
			
			# Security Police
			security = R.by_id "Security"				
			security.permissions = security.permissions + ["development"]
			
			developer = Security::Model::Role.new("Developer").set!(:permissions => ["development"])
			security.roles << developer
			
			dev_policy = Security::Model::Policy.new "Development Policy"
			dev_policy.map = {
				developer.entity_id => {dev_group.entity_id => true},
			}		
			
			security.policies << dev_policy
			
			# Setting Policy
			dev.set_policy dev_policy
		}.commit
	end
end