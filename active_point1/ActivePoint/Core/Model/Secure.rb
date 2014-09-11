module Secure
	inherit Entity
	
	metadata do
		reference :object_policy
		reference :object_owner
	end	
end