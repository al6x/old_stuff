class EditWiget < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Edit Wiget`
		attributes do
			add `Name`, :string_edit, :attr => :name
			
			str_to_class = lambda do |str|
				klass = eval(self[:wiget_class].value, TOPLEVEL_BINDING, __FILE__, __LINE__)
				klass.class.should! :be_in, [Module, Class]
				klass
			end
			add `Wiget Class`, :string_edit, :attr => :wiget_class, 
			:before_read => lambda{|c| c ? c.name : ""}, 
			:before_write => str_to_class
			
			add `Accessor`, :string_edit, :attr => :accessor, :before_read => lambda{|c| c ? c.to_s : ""}, 
			:before_write => lambda{|str| str.strip.empty? ? nil : str.to_sym}
			
			add `Parameters`, :text_edit, :attr => :parameters, 
			:before_read => lambda{|o| YAML.dump o}, :before_write => lambda{|str| YAML.load str}
		end
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end				
	end
end