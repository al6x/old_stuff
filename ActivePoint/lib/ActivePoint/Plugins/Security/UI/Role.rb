class Role	
	inherit Controller
	editor EditRole
	
	def show
		@view = Form.common_form :box, :object => C.object, :css => "padding" do
			set :title => object.name
			
			list_view :attr => :permissions
			line :wide => false do
				button :text => `Edit`, :action => :edit
				button :text => `Edit Permissions`, :action => :edit_permissions
			end
		end
	end
	
	def edit
		R.transaction_begin
		@view = EditRole.new.set :object => C.object
		@view.on[:ok] = lambda do						
			R.transaction{C.object.set @view.values}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	def edit_permissions
		R.transaction_begin
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values], :multiple => true
		end
		@view.on[:ok] = lambda do						
			R.transaction{C.object.permissions = @view[:value].value}.commit
			show
		end
		@view.on[:cancel] = lambda{show}	
		@view.object = {:value => C.object.permissions, :values => R.by_id("Security").permissions, 
			:title => `Edit Permissions`}
	end
end