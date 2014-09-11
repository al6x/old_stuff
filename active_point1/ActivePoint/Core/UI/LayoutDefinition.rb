class LayoutDefinition	
	inherit Controller
	
	def initialize
		@view = View.new
		@view.object = C.object
	end
	
	def edit_layout
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
	
	def add_to_center; add_to :center end
	def delete_from_center; delete_from :center end
	
	def add_to_left; add_to :left end
	def delete_from_left; delete_from :left end
	
	def add_to_top; add_to :top end
	def delete_from_top; delete_from :top end
	
	def add_to_right; add_to :right end
	def delete_from_right; delete_from :right end
	
	def add_to_bottom; add_to :bottom end
	def delete_from_bottom; delete_from :bottom end
	
	protected	
	def add_to position
		C.transaction_begin
		form = WebClient::Templates::Select.new
		form.title = "Add Tool"
		form.on_ok = lambda do						
			tool_name = form[:select].value
			raise "Tool not selected!" if tool_name.empty?
			tool = R["Core/Tools"][tool_name]
			R.transaction{
				o = C.object
				list = o.send position
				list << tool
			}.commit
			view.object = C.object
			view.refresh
		end
		form.on_cancel = lambda{view.cancel}		
		form.parameters = {:values => R["Core/Tools"].tools.collect{|l| l.name}}
		form.object = {:select => ""}
		view.subflow form
	end
	
	def delete_from position
		Scope.begin :transaction		
		R.transaction{
			list = C.object.send position
			view[position].selected.each{|ref| list.delete ref}
		}.commit
		view.object = C.object
		view.refresh
	end
end