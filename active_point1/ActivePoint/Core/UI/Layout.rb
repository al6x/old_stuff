module Layout
	inherit Controller
	
	def layout_set
		C.object.should! :be_a, Model::Layout
		
		C.transaction_begin
		form = WebClient::Templates::Select.new
		form.title = "Set Layout"
		form.on_ok = lambda do						
			layout_name = form[:select].value
			raise "Layout not selected!" if layout_name.empty?
			layout = R["Core/Layouts"][layout_name]
			R.transaction{
			o = C.object
				o.wc_layout = layout
			}.commit
			view.object = C.object
			view.refresh
		end
		form.on_cancel = lambda{view.cancel}		
		form.parameters = {:values => R["Core/Layouts"].layouts.collect{|l| l.name}}
		form.object = {:select => ""}
		view.subflow form
	end
	
	def layout_delete
		C.transaction_begin
		C.object.should! :be_a, Model::Layout
		
		R.transaction{
			C.object.wc_layout = nil
		}.commit
		view.object = C.object
		view.refresh
	end
end