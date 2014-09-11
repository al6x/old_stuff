class Users
	inherit Entity
	
	metadata do
		child :users, :bag
	end	
	
	alias_method :name, :entity_id
	alias_method :name=, :entity_id=
end