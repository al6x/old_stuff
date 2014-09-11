class Security
	include MonitorMixin
	
	def initialize
		super
		@logged_users = Set.new
	end
	
	def login name, password
		C.should! :anonymous?
		
		users = R["Core/Users"]
		return false unless users.include? name
		
		user = users[name]
		if user.password == password
			Scope[:user] = user.om_id
			Scope.group(:object).begin
			
			return true
		else
			return false
		end
	end
	
	def logout name
		C.should_not! :anonymous?
		
		Scope[:user] = Core::Model::AnonymousUser::ID
		Scope.group(:object).begin		
	end
end