class SetUrls
	def initialize uri_builder
		@uri_builder = uri_builder
		@parent_portlet = nil
	end
	
	def accept wiget		
		if wiget.is_a? Link
			portlet = wiget.portlet || @parent_portlet
			unless portlet
				raise "Link can be used only inside the WPortlet component or explicitly provide WPortlet link (link: #{wiget.component_id})!" 
			end
			unless portlet.is_a?(Core::WPortlet)
				raise "The '#{portlet}' isn't Portlet!"
			end
			wiget.evaluated_uri = @uri_builder.evaluate_uri portlet.component_id, wiget.state, wiget.get_alter_state
		elsif wiget.is_a? WPortlet
			@parent_portlet = wiget
		end		
		return true
	end
end