class User	
	inherit Controller
	
	def initialize
		@view = View.new
		@view.object = C.object
	end
	
	def edit_user
		C.transaction_begin
		form = Edit.new
		form.on_ok = lambda do						
			R.transaction{
				o = C.object
				o.set form.values
			}.commit
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = C.object		
		@view.subflow form
	end
	
	def delete_user
		C.transaction_begin
		parent = C.object.parent
		R.transaction{C.object.delete}.commit
		C.object = parent
	end		
end