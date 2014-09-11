class Edit < WComponent
	inherit UView
	
	attr_accessor :on_ok, :on_cancel
	
	build_view do |v|
		form = v.new :box, :style => "float border_left border_top input padding", :title => "Edit Tool Definition"
		v.root = form
		
		attrs = v.new :attributes
		form.add attrs		
		attrs.add "Name", v.new(:string_edit, :name => :name)
		attrs.add "Class", v.new(:string_edit, :name => :tool_class, :before_read => lambda{|c| c.to_s})
		attrs.add "Parameters", v.new(:text_edit, :name => :parameters_source)
		
		controls = v.new :flow, :style => "minimal input padding"
		form.add controls		
		controls.add v.new(:button, :text => "Ok", :action => [form, v.on_ok])
		controls.add v.new(:button, :text => "Cancel", :action => v.on_cancel)
	end
	
	def values
		klass = eval(self[:tool_class].value, TOPLEVEL_BINDING, __FILE__, __LINE__)
		raise "Invalid Class!" unless klass and klass.is? WGUI::Wiget
		values = super
		values[:parameters] = eval(self[:parameters_source].value, TOPLEVEL_BINDING, __FILE__, __LINE__)
		return values
	end
end