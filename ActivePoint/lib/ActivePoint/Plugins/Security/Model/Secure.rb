module Secure
	inherit Entity
	
	metadata do
		name "Secure"
		reference :object_policy
		reference :object_owner
		after :new_reference, :clear_security_cache
		after :delete_reference, :clear_security_cache
	end	
	
	def set_policy policy
		if policy
			self.object_policy = policy
			policy.included_in << self
		else
			self.object_policy = nil
		end
	end
	
	def clear_security_cache attr, old_value
		self._effective_permission_cache_clear if attr == :object_policy or attr == :object_owner
	end
end