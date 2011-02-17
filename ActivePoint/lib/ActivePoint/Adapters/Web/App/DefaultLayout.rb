class DefaultLayout < WComponent
	inherit Form
	
	build :line, :css => "padding" do
		add WGUIExt::Containers::Wrapper.new.set!(:component => "User Menu")
		box :css => "padding" do
			add WGUIExt::Containers::Wrapper.new.set!(:component => "Messages")
			add WGUIExt::Containers::Wrapper.new.set!(:component => :controller, :accessor => :view)		
		end
	end
end