module SecureMethods
	inherit Log	
	
	module ClassMethods
		def secure params
			params.should! :be_a, Hash
			
			self_permissions.clear
			params.each do |method, perm|
				instance_methods.should! :include, method.to_s
				perm.should! :be_a, [String, Symbol, Proc]
				perm = perm.to_s if perm.is_a? Symbol
				
				self_permissions[method] = perm
			end
		end
		
		def editor editor = nil
			unless editor
				return @editor.should_not! :be_nil
			else
				editor.should! :be, WGUI::Wiget
				@editor = editor				
			end
		end
		
		def self_permissions
			@self_permissions ||= {}
		end
		
		def permissions
			permissions = ancestors.reverse.inject nil do |r, a| 
				if a.respond_to? :self_permissions
					self_permissions.should_not! :be_nil
					r ? a.self_permissions.merge(r) : a.self_permissions
				else
					r
				end
			end			
			return permissions			
		end
		
		def can_execute_method? user, object, method, *args
			permission = self.permissions[method]
			return true unless permission
			
			result = if permission.is_a? String
				Scope[:services][:security].can? user, permission, object
			elsif permission.is_a? Proc
				permission.call *args
			else
				should! :be_never_called			
			end
			return result
		end
	end				
end