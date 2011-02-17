class Policy
	inherit Entity
	
	metadata do
		name "Policy"
		attribute :map, :object, :initialize => {} # Roles => [Groups]
		reference :included_in, :bag
		before :commit do
			included_in.every._effective_permission_cache_clear
		end
	end
	
#	def policy
#		map
#	end
	
	def inherit map
		inherited = map.merge self.map do |key, old, new|
			old.merge new
		end
		return inherited
	end
end