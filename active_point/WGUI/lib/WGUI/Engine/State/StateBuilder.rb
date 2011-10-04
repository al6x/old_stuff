class StateBuilder
	include Log
	
	def initialize path, state_params, root_portlet_id
		@half_state = {}
		#		@half_state[Core::WPortlet::ROOT] = state_path unless Path.new(state_path).empty?
		state_params.each do |name, value|
			next if name == BrigeServlet::SESSION_ID
			
			@half_state[name] = value
		end
		@half_state[root_portlet_id] = path.to_relative.to_s if root_portlet_id != nil
		@state = {}
		@valid_state = true
	end
	
	def state;
		#		return @half_state.merge(@state), @conversion_strategies
		return @state
	end
	
	def convert wp
		strategy = PortletHelper.state_conversion_strategy wp
		return strategy.empty_state unless @half_state.include? wp.component_id
		begin
			p_state = strategy.uri_to_state(@half_state[wp.component_id])
		rescue Exception => e
			p_state = strategy.empty_state
			@valid_state = false
			log.warn "Invalid uri parameter '#{@half_state[wp.component_id]}' (Error: #{e.message})!"
		end
		if p_state && !p_state.empty?
			@state[wp.component_id] = p_state
			return p_state
		else
			return strategy.empty_state
		end
	end
	
	def valid_uri?
		@valid_state and (@state.size == @half_state.size)
	end
end