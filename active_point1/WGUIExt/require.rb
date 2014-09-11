module WGUIExt
	extend RubyExt::ImportAll
	import_all WGUI	
	
	dir = File.dirname __FILE__
	DEFAULT_CSS = "default_style/style.css"
	Scope[WGUI::Engine::StaticResource].add_file DEFAULT_CSS, "#{dir}/data/default_style/style.css" 
end