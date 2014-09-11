class ToolDefinition
	attr_reader :view
	
	def initialize
		@view = View.new
		@view.object = C.object
	end
	
	def edit_tool
		form = Edit.new
		form.on_ok = lambda do						
			R.transaction{								
				o = C.object
				o.set form.values
				o.validate
			}.commit
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = C.object		
		@view.subflow form
	end
end