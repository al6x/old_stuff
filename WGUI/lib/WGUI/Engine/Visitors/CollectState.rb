class CollectState
	attr_accessor :state, :conversion_strategies
	def initialize; @state, @conversion_strategies = {}, {} end
	
	def accept wiget
		if wiget.is_a? WPortlet
			state = wiget.state
			@state[wiget.component_id] = state if state and !state.empty?
			@conversion_strategies[wiget.component_id] = State::PortletHelper.state_conversion_strategy(wiget)
		end
		return true
	end
end