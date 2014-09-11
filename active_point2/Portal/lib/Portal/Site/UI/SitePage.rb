class SitePage
	inherit Controller
	inherit C::UI::Secure
	inherit C::UI::Layout
	inherit Aspects::UI::Container	
	
	editor EditSitePage
	
	def show
		@view = ShowSitePage.new.set :object => C.object		
	end
	
	def edit_page
		R.transaction_begin
		@view = EditSitePage.new.set :object => C.object
		@view.on[:ok] = lambda do						
			R.transaction{C.object.set @view.values}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	secure :edit_page => :edit
end