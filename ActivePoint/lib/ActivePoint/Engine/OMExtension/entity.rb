module ::ObjectModel
	DEFAULT_POLICY = {}
	
	module Entity
		def effective_policy
			ep = _effective_policy
			if ep
				return ep
			else
				dp = R.by_id("Security").default_policy
				return dp ? dp.map : DEFAULT_POLICY
			end
		end
		
		def effective_permissions
			unless @_effective_permission_cache
				permissions_to_groups = {}
				effective_policy.each do |role_id, groups|
					role = R.by_id role_id
					role.permissions.each do |permission|
						permissions_to_groups[permission] ||= {}
						permissions_to_groups[permission].merge! groups
					end
				end
				@_effective_permission_cache = permissions_to_groups
			end
			return @_effective_permission_cache
		end
		
		# Used in ObjectModel's Listener, Policy and Secure
		def _effective_permission_cache_clear
			@_effective_permission_cache = nil			
			each(:child){|child| child._effective_permission_cache_clear}
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
						return object_policy.map
					end
				else
					return object_policy.map
				end
			else 
				parent = self.parent
				if parent
					parent_policy = parent._effective_policy
					if parent_policy
						return parent_policy
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