class Config
	extend Configurator
	
	depends_on Core
	
	initialize_data do
		R.transaction(Transaction.new){
			core = R.by_id "Core"
			users = Model::Users.new("Users", "Users")
			core.plugins << users						
			
			# Users
			anonymous = Model::User.new(Model::User::ANONYMOUS, Model::User::ANONYMOUS)
			users.users << anonymous
			
			administrator = Model::User.new(Model::User::ADMINISTRATOR, Model::User::ADMINISTRATOR)
			#			administrator.password = Model::User::ADMINISTRATOR
			users.users << administrator
			
			# Groups
			anonymous_group = Model::Group.new(Model::Group::ANONYMOUS, Model::Group::ANONYMOUS)
			anonymous_group.add_user anonymous
			users.groups << anonymous_group
		}.commit
	end
end