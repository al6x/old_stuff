class Config
	extend Configurator
	
	depends_on ::ActivePoint::Services::WebServer
	
	activate do
		module ::ActivePoint::Adapters::Web
			extend Log
			
			SKINS = "Skins"	
			UI_NAME = "UI"
			DIRECTORY_NAME = "Web"
		end
		
		require 'WGUI/require'
		require 'WGUIExt/require'		
		
		# Require				
		dir = File.dirname __FILE__
		require "#{dir}/extensions/wgui_ext"
		require "#{dir}/extensions/wgui"												 
		
		# Scopes
		Scope.register :object, :object
		
		Scope.group(:object) << :transaction		
		Scope.group(:object) << :object									
		
		Scope.register :user, :user do
			Plugins::Users::Model::User::ANONYMOUS
		end
		
		Scope.register :controller, :object do
			Scope[AppController]._create_controller
		end
		
		Scope.before :session do
			Scope.group(:object).begin
			Scope.begin :user
		end
		
		CONFIG[:web_app_directory] = File.join(CONFIG[:directory].should_not!(:be_empty), DIRECTORY_NAME)
		CONFIG[:skins_directory] = "#{CONFIG[:web_app_directory]}/#{SKINS}"
		
		# Handy Scope
		::Form = WGUIExt::Form
		::Controller = ActivePoint::Adapters::Web::Controller				
		require "#{dir}/handy_scope"
		class ::Object
			alias :` :to_l
		end
		
		# Cache
		Cache.cached :class, Adapters::Web::Controller.singleton_class, :permissions				
		Cache.cached_with_params :class, WGUI::Utils::TemplateHelper.singleton_class, :_generate_template_id
	end
	
	startup do
		Scope[WGUI::Engine::StaticResource].add_path CONFIG[:web_app_directory]		
		
		# Extensions
		R.entity_listeners << AppController::Listener.new
		
		# SetUp Webserver
		app = WGUI.rack_app(App, CONFIG[:wgui_prefix], "object")
		Scope[:services][:webserver].map CONFIG[:wgui_prefix], app
	end
	
	restart do
		R.entity_listeners << AppController::Listener.new  # TODO Stub, shouldn't do this. 
		# Will be deleted when Engine willn't be created new R for restart.
	end	
	
	initialize_data do		
		[CONFIG[:web_app_directory], CONFIG[:skins_directory]].each do |d| 
			File.create_directory d
		end
	end
	
	clear_data do
		[CONFIG[:web_app_directory], CONFIG[:skins_directory]].each do |d| 
			File.delete_directory d
		end
	end
end