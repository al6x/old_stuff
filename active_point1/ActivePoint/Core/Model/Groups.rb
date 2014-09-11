class Groups
	inherit Entity
	
	metadata do
		child :groups, :bag
	end	
	
	alias_method :name, :entity_id
	alias_method :name=, :entity_id=
end