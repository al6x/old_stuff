module ActivePoint		
	module WebClient				
		Scope.register :controller, :object do
			Scope[Engine::APController]._create_controller
		end				
		
		class << self
			def init
				wc_dir = CONFIG[:web_client_directory] = File.join(CONFIG[:directory].should_not!(:be_empty), "WebClient")
				CONFIG[:skins_directory] = "#{wc_dir}/skins"
				[CONFIG[:web_client_directory], CONFIG[:skins_directory]].each{|d| File.create_directory d}
				Scope[WGUI::Engine::StaticResource].add_path wc_dir
			end
			
			def initialize_database				
													
			end
		end				
		
		Scope.before :session do
			Scope[Engine::APController].add_observer Scope[WCController]
		end
	end		
	
	require 'ActivePoint/WebClient/Client/ap_controller'
	require 'ActivePoint/WebClient/Client/wgui_extension'
	require 'ActivePoint/WebClient/Client/wgui_ext_extension'
end

# HandyScope
C = ActivePoint::Engine::C.new
UView = WGUIExt::View

# Cache
Cache.cached_with_params :class, ActivePoint::Engine::APController.singleton_class, :ui_controller_for	