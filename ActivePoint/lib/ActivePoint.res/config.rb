{
	:directory => "./data",
	:port => 8080,
	
	:default_object => 'Core', 
	:wgui_prefix => "/ui", 
	:rest_prefix => "/rest",
	
	:after_start => lambda{},
	:initialize => lambda{},
	:initialize_core => lambda{Plugins::Core::Model::Core.new("Core", "Core")},			
	
	:disable_security => false,
	:reset_data => false,
	:reloading => true,
	
	:languages => {:en => "English", :ru => "Русский"},	
	:default_language => :en,
	
#	:cache => "::ObjectModel::Tools::OGLRUCache",
	
	:core_adapters => [
	Adapters::Web,
	Adapters::Rest,
	],
	:core_services => [
	Services::Security,
	Services::Localization,
	Services::WebServer,
	],
	:core_plugins => [
	Plugins::Core,
	Plugins::Users,
	Plugins::Security,
	Plugins::Appearance,
	Plugins::Development,
	],
	
	:adapters => [],
	:services => [],
	:plugins => [
	Plugins::Samples::Welcome
	],
}