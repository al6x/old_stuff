class Policy
	inherit Entity
	
	metadata do
		attribute :map, :object, :initialize => lambda{{}} # Roles => [Permissions]
		reference :included_in, :bag
	end
	
	alias_method :name, :entity_id
	alias_method :name=, :entity_id=
	
	def policy
		map
	end
	
	def inherit policy
		inherited = policy.map.merge map do |key, old, new|
			old.merge new
		end
		return inherited
	end
end