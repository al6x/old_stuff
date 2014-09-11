class ShowCustomLayout < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Custom Layout`
		attributes do
			add `Name`, :string_view, :attr => :name
			add `Class`, :string_view, :attr => :layout_class, 
			:before_read => lambda{|c| c ? c.name : ""}
			add `Parameters (YAML)`, :text_view, :attr => :parameters, 
			:before_read => lambda{|o| o ? YAML.dump(o) : ""}
		end
		button :text => `Edit`, :action => :edit_wiget
	end
end