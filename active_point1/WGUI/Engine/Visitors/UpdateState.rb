# Converts and calls 'update_state' on portlets.
class UpdateState
	def initialize state_builder
		@state_builder = state_builder
	end
		
	def accept wiget            
		if wiget.is_a? Core::WPortlet						
			# Convert state from URI-form to WPortlet-form
			state = @state_builder.convert wiget
			
			# Update Portlet state if changed 
#			empty_state = State::PortletHelper.state_conversion_strategy(wiget).empty_state
#			State::PortletHelper.set_previous_state(wiget, empty_state) if State::PortletHelper.get_previous_state(wiget) == nil
			
#			previous_state = State::PortletHelper.get_previous_state(wiget)			
			if  wiget.state != state
				# Updating state
				wiget.state = state.clone
				wiget.update_state
			end						
		end
	end
end