class CustomLayout
	inherit Entity
	
	metadata do
		name "Custom Layout"
		attribute :layout_class, :class
		attribute :parameters, :object
	end
	
	def build_layout
		layout_class.should! :be, WGUI::Wiget
		
		layout = layout_class.new		
		layout.set_with_check parameters if parameters
		return layout
	end
end