class ExclusiveLayout < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		add WGUIExt::Containers::Wrapper.new.set!(:component => "Messages")
		add WGUIExt::Containers::Wrapper.new.set!(:component => Adapters::Web::App, :accessor => :exclusive)		
	end
end