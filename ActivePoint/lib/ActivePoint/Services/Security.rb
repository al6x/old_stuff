class Security
	extend Configurator
	
	def initialize
		super
		#		@logged_users = Set.new
	end
	
	def can? user, permission, object
		object.should! :be_a, Entity
		permission.should! :be_a, [Symbol, String]
		permission = permission.to_s if permission.is_a? Symbol
		
		return true if CONFIG[:disable_security] or user.administrator?
		
		groups_to_perm = object.effective_permissions[permission]
		unless groups_to_perm
			false
		else
			result = false
			user.groups.each do |group|
				if groups_to_perm[group.entity_id]
					result = true
					break
				end
			end				
			result
		end						
	end
			
	def user_for name, password
		users = R.by_id("Core")["Users"]
		if users.include? name		
			anonymous = R.by_id(Plugins::Users::Model::User::ANONYMOUS)
			raise SecurityError, "Forbiden to use 'Anonymous' Name!" if name == anonymous.name
			
			user = users[name]		
			return user if user.password == password							
		end
		raise SecurityError, `User with such Name and Password not found!`					
	end			
	
	startup do
		Scope[:services][:security] = Security.new
	end
end