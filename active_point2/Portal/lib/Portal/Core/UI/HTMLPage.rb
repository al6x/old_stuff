class HTMLPage < WComponent
	inherit Controller
	editor EditHTMLPage
	
	inherit C::UI::Secure
	inherit C::UI::Layout
	
	def show	
		@view = ShowHTMLPage.new.set :object => C.object		
	end
	
	def edit
		R.transaction_begin
		@view = EditHTMLPage.new
		@view.on[:ok] = lambda do						
			R.transaction{C.object.set @view.values}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
		@view.object = C.object		
	end		
	
	def delete
		R.transaction_begin
		parent = C.object.parent
		R.transaction{C.object.delete}.commit
		C.object = parent
	end		
	
	secure :edit => :edit, :delete => :delete
end