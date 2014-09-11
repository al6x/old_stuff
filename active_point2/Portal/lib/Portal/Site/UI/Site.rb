class Site 
	inherit Controller
	inherit C::UI::Secure
	inherit C::UI::Layout
	inherit C::UI::Skinnable	
	inherit Aspects::UI::Container	
	
	editor Site::EditSite
	
	def show
		@view = ShowSite.new.set :object => C.object		
	end
	
	def edit
		R.transaction_begin
		@view = EditSite.new.set :object => C.object
		@view.on[:ok] = lambda do						
			R.transaction{C.object.set @view.values}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	secure :edit => :edit
end