class Core
	inherit Controller	
	inherit Appearance::UI::Layout
	inherit Appearance::UI::Skinnable
	inherit Security::UI::Secure
	
	def show
		@view = Form.common_form :tab, :object => C.object, :component_id => :tab_core do
			set! :title => ActivePoint::Plugins::Core.to_l("Core"), :active => ActivePoint::Plugins::Core.to_l("Plugins")
			add Plugins::Core::UI.to_l("Plugins"), :table, :attr => :plugins, :css => "padding" do
				body{link :value => object, :text => object.class.to_l(object.name)}
			end
			
			add ActivePoint::Plugins::Core::UI.to_l("Properties"), :box, :css => "padding" do
				add Appearance::UI::Layout::ShowLayout.new.set(:object => object)
				add Appearance::UI::Skinnable::ShowSkinnable.new.set(:object => object)
				add Security::UI::Secure::ShowSecure.new.set(:object => object)
			end
		end
	end		
end