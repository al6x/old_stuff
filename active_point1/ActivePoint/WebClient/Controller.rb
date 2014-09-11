module Controller
	inherit Log
	
	attr_reader :view
	
	module ClassMethods
		def secure params
			params.should! :be_a, Hash
			
			permissions.clear
			params.each do |method, perm|
				instance_methods.should! :include, method.to_s
				perm = [perm] unless perm.is_a? Array
				
				permissions[method] = perm
				
				script = %{\
def #{method}
	secure_method :#{method}
end}
				self.class_eval{alias_method :"#{method}_original", method.to_sym}
				self.class_eval script, __FILE__, __LINE__
			end
		end
		
		def permissions
			@permissions ||= {}
		end
	end		
	extend ClassMethods
	
	def secure_method method	
		m_permissions = self.class.permissions[method]
		if m_permissions and !m_permissions.all?{|perm| C.can? perm}		
			log.warn "User '#{C.user.name}' hasn't permission '#{m_permissions}' needed to execute '#{self.class.name}.#{method}'!"
			raise UserError, "You hasn't permission!"
		end
		send :"#{method}_original"
	end
end