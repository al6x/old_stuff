class Role
	inherit Entity
	
	metadata do
		name "Role"		
		attribute :permissions, :object, :initialize => Set.new
	end
end