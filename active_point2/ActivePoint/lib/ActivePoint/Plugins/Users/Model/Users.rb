class Users
	inherit Entity
	
	metadata do
		name "Users"
		
		child :groups, :bag
		child :users, :bag
	end	
end