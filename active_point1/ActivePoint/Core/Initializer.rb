class Initializer
	def check_and_initialize
		return if R.include? "Core"
		initialize_core
		initialize_layouts
		initialize_policies
		initialize_users
		initialize_tools
	end
	
	protected 
	def initialize_core
		R.transaction(Transaction.new){
			Model::Core.new("Core", "Core")
		}.commit
	end
	
	def initialize_layouts
		R.transaction(Transaction.new){
			core = R["Core"]
			core.plugins << Model::Layouts.new("Layouts", "Layouts")
		}.commit
	end
	
	def initialize_policies
		R.transaction(Transaction.new){
			core = R["Core"]
			policies = Model::Policies.new("Policies", "Policies")
			policies.permissions = Model::Policy["permissions.rb"]
			core.plugins << policies
			
			
			policy = Model::Policy.new("Test Policy")
			policies.policies << policy
			
			policy.map = {
					"Edit" => {"Editor" => true, "Viewer" => false},
					"View" => {"Viewer" => true},
			}
		}.commit
	end
	
	def initialize_users
		R.transaction(Transaction.new){
			core = R["Core"]
			users = Model::Users.new("Users", "Users")
			core.plugins << users
			
			anonymous_user = Model::AnonymousUser.new("AnonymousUser", Model::AnonymousUser::ID)
			users.users << anonymous_user 
			
			groups = Model::Groups.new("Groups", "Groups")
			core.plugins << groups
			
			groups.groups << Model::OwnerGroup.new("Owner", Model::OwnerGroup::ID)
			anonymous_group = Model::AnonymousGroup.new("AnonymousGroup", Model::AnonymousGroup::ID)
			anonymous_group.users << anonymous_user
			anonymous_user.included_in << anonymous_group
			groups.groups << anonymous_group
		}.commit
	end
	
	def initialize_tools
		R.transaction(Transaction.new){
			core = R["Core"]
			core.plugins << Model::Tools.new("Tools", "Tools")
		}.commit
	end
end