class Tools
	attr_reader :view
	
	def initialize
		@view = ToolsList.new
		@view.object = C.object
	end
	
	def add_tool
		C.transaction_begin
		new_tool = nil
		R.transaction{new_tool = Model::ToolDefinition.new}
		form = ToolDefinition::Edit.new
		form.on_ok = lambda do					
			R.transaction{
				new_tool.set form.values				
				new_tool.validate
				
				C.object.tools << new_tool
			}.commit	
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = new_tool
		@view.subflow form
	end
	
	def delete_tools
		C.transaction_begin
		R.transaction{
			@view[:tools].selected.every.delete
		}.commit
		@view.object = C.object
		@view.refresh
	end
end