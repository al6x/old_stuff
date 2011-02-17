class CustomLayout
	inherit Controller
	editor EditCustomLayout
	
	def show
		@view = ShowCustomLayout.new.set :object => C.object
	end
	
	def edit_wiget
		@view = EditCustomLayout.new.set :object => C.object
		@view.on[:ok] = lambda do						
			R.transaction{C.object.set @view.values}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
	end
end