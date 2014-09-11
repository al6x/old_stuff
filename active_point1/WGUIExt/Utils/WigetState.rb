module WigetState
	def view_state		
		Extension.view_state_get component_id
	end
	
	def view_state= state
		Extension.view_state_set component_id, state
	end
end