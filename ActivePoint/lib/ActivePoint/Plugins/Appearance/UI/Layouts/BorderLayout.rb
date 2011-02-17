class BorderLayout
	inherit Controller
	editor EditBorderLayout
	
	def show
		@view = ShowBorderLayout.new.set :object => C.object
	end
	
	def edit_layout
		@view = EditBorderLayout.new.set :object => C.object
		@view.on[:ok] = lambda do						
			R.transaction{C.object.set @view.values}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	def add_to position
		R.transaction_begin
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values]
		end
		@view.on[:ok] = lambda do						
			wiget_name = @view[:value].value
			raise `Wiget not selected!` if wiget_name.empty?
			wiget = R.by_id("Appearance")[wiget_name]
			R.transaction{
				o = C.object
				list = o.send position
				list << wiget
			}.commit
			show
		end
		@view.on[:cancel] = lambda{show}		
		values = R.by_id("Appearance").wigets.collect{|l| l.name}
		@view.object = {:value => "", :title => `Add Wiget`, :values => values}
	end
	
	def delete_from position
		Scope.begin :transaction		
		R.transaction{
			list = C.object.send position
			@view[position].selected.each{|ref| list.delete ref}
		}.commit
		show
	end
end