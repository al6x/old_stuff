{
	:default_object => 'Welcome', 
	:wgui_prefix => "/ui", 
	:web_services_prefix => "/ws",
	:reloading => true,
	:initialize => lambda{},
	:before_run => lambda{},
	:plugins => [ActivePoint::Samples::Welcome]
}