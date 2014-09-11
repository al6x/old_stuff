class Extension	
	class << self		
		def get_data_storage
			should! :be_never_called
		end
		
		def get_name object
			should! :be_never_called
		end
		
		def get_portlet
			should! :be_never_called
		end
		
		def view_state_get component_id
			should! :be_never_called
		end
		
		def view_state_set component_id, state
			should! :be_never_called
		end
		
		def get_state object
			should! :be_never_called
		end
	end
end