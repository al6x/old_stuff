module ::ObjectModel
	DEFAULT_POLICY = {}
	
	module Entity
		def effective_policy
			ep = _effective_policy
			if ep
				return ep
			else
				dp = R.by_id("Policies").default_policy
				return dp ? dp.policy : DEFAULT_POLICY
			end
		end
		
		def _effective_policy
			object_policy = respond_to(:object_policy)									
			if object_policy
				parent = self.parent
				if parent
					parent_policy = parent._effective_policy
					if parent_policy
						return object_policy.inherit parent_policy
					else
						return object_policy.policy
					end
				else
					return object_policy.policy
				end
			else 
				parent = self.parent
				if parent
					parent_policy = parent._effective_policy
					if parent_policy
						return parent_policy.policy
					else 
						return nil
					end
				else
					return nil
				end
			end		
		end
	end
end