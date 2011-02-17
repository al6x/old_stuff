class Security
	inherit Entity
	
	metadata do
		name "Security"
		
		attribute :permissions, :object, :initialize => Set.new
		
		child :roles, :bag
		
		child :policies, :bag	
		reference :default_policy				
	end
end