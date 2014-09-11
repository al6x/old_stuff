class EditCustomLayout < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Edit Custom Layout`
		attributes do
			add `Name`, :string_edit, :attr => :name
			
			str_to_class = lambda do |str|
				klass = eval(str, TOPLEVEL_BINDING, __FILE__, __LINE__)
				raise `Invalid Class!` unless klass and klass.is? WGUI::Wiget
				klass
			end
			add `Class`, :string_edit, :attr => :layout_class,
			:before_read => lambda{|c| c ? c.name : ""},
			:before_write => str_to_class
			
			add `Parameters (YAML)`, :text_edit, :attr => :parameters, 
			:before_read => lambda{|o| o ? YAML.dump(o) : ""}, 
			:before_write => lambda{|str| str.strip.empty? ? nil : YAML.load(str)}
		end
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
 			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end