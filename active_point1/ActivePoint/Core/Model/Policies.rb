class Policies
	inherit Entity
	
	metadata do
		attribute :permissions, :object, :initialize => lambda{Set.new}
		child :policies, :bag	
		reference :default_policy
	end	
	
	alias_method :name, :entity_id
	alias_method :name=, :entity_id=
end