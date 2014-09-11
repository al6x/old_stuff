class Layouts
	inherit Controller
	
	def initialize
		@view = LayoutsList.new
		@view.object = C.object
	end
	
	def add_layout
		C.transaction_begin
		new_layout = nil
		R.transaction{new_layout = Model::LayoutDefinition.new}
		form = LayoutDefinition::Edit.new
		form.on_ok = lambda do					
			R.transaction{
				new_layout.set form.values				
				new_layout.validate
				
				C.object.layouts << new_layout
			}.commit	
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = new_layout
		@view.subflow form
	end
	
	def delete_layouts
		C.transaction_begin
		R.transaction{
			@view[:layouts].selected.every.delete
		}.commit
		@view.object = C.object
		@view.refresh
	end
end