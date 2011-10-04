module Layout
	inherit Controller
	
	def layout_set
		restore = @view
		R.transaction_begin
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values]
		end
		@view.on[:ok] = lambda do						
			layout_name = @view[:value].value
			layout = if layout_name.empty?
				nil
			else
				R.by_id("Appearance")[layout_name]
			end
			R.transaction{
				o = C.object
				o.wc_layout = layout
			}.commit
			@view = restore
			@view.object = C.object
		end
		@view.on[:cancel] = lambda{@view = restore; @view.refresh}		
		layouts = R.by_id("Appearance").layouts.collect{|l| l.name}
		layouts << ""
		@view.object = {
		:value => C.object.wc_layout, :values => layouts, 
		:title => ActivePoint::Plugins::Appearance.to_l("Select Layout")
		}
	end
	
	secure :layout_set => :manage
end