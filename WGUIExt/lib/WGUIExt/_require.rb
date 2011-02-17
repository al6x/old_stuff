require 'WGUI/require'

module WGUIExt
	extend RubyExt::ImportAll
	import_all WGUI	
	remove_const :Wigets # WGUI::Wigets interfere with WGUIExt::Wigets
	
	dir = File.dirname __FILE__
	DEFAULT_STYLE = "default_style"
	Scope[WGUI::Engine::StaticResource].add_path "#{dir}/../../data" 
	
#	CONFIG.merge WGUIExt["config.yaml"]
end