class PortletHelper
#	def self.get_previous_state portlet
#		portlet.instance_variable_get :@portlet_helper_previous_state
#    end
#	
#	def self.set_previous_state portlet, state
#		portlet.instance_variable_set :@portlet_helper_previous_state, state
#    end
	
	def self.state_conversion_strategy portlet
		portlet.class.respond_to?(:state_conversion_strategy) ? \
			portlet.class.state_conversion_strategy : DefaultStateConversionStrategy
    end
end