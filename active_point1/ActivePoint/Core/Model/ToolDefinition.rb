class ToolDefinition
	inherit Entity
	
	metadata do
		attribute :tool_class, :string
		attribute :parameters, :object
		attribute :parameters_source, :string
	end
	
	def build_tool
		klass = eval tool_class, TOPLEVEL_BINDING, __FILE__, __LINE__
		tool = klass.new
		tool.should! :be_a, WGUI::Wiget
		parameters.should! :be_a, [NilClass, Hash]
		
		tool.set_with_check parameters if parameters
		return tool
	end
	
	alias_method :name, :entity_id
	alias_method :name=, :entity_id=
end