module WGUIExt	
	module Utils
		class Extension
			class << self
				def get_data_storage
					Scope[:repository]
				end
				
				def get_name object
					object.entity_id
				end
				
				def get_portlet
					Scope[ActivePoint::WebClient::Client]
				end
				
				def view_state_get component_id
					Scope[ActivePoint::WebClient::Client::WigetsState][component_id]
				end
				
				def view_state_set component_id, state
					Scope[ActivePoint::WebClient::Client::WigetsState][component_id] = state
				end
				
				def get_state object
					object.entity_path
				end
				
				def get_id object
					object.om_id
				end
			end
		end		
	end		
	
	Controls::Control
	module Controls::Control
		def action= params
			inputs, action = if params.is_a? Array
				params.size.should! :==, 2
				[params[0], params[1]]
			else 			
				[[], params]
			end		
			action.should! :be_a, [Symbol, Proc]
			if action.is_a? Symbol
				@action_method = action
				action = lambda{C.controller.send @action_method} 
			end
			
			self.action inputs, &action
		end
		
		def visible?
			return false unless super
			
			if @action_method
				m_permissions = C.class.permissions[@action_method]
				if m_permissions and !m_permissions.all?{|perm| C.can? perm}
					false
				else
					true
				end
			else
				true
			end
		end
	end
	
	View
	module View			
		def aspects
			self[:aspects] ||= new :box
		end
		
		alias_method :original_read, :read
		def read
			R.transaction{original_read}
		end
	end
end