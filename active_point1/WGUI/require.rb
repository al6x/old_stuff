# Ruby
require 'RubyExt/require'
require 'json'

# eRubis
require 'erubis'

# Rack
require 'rack'
require 'rack/lint'
require 'rack/showexceptions.rb'
require 'rack/session/pool.rb'
require 'rack/utils'

# RubyfulSoup
require 'rubyful_soup'
require 'rexml/document'
#require 'rexml/formatters/transitive'

require 'RubyExt/debug'

# MicroContainer
require 'MicroContainer/require'
module WGUI
	Managed = MicroContainer::Managed
	Injectable = MicroContainer::Injectable
	Scope = MicroContainer::Scope
end

# Constants
module WGUI
	RESOURCE = "__res__"
	STATIC_RESOURCE = "__sr__"
	TEMPLATE_EXTENSION = "rhtml"
end

# Localization
require 'RubyExt/Localization/require'
module WGUI
	RubyExt::Localization.language = lambda{Scope[Engine::Window].language}
end

# Config
module WGUI
	CONFIG = WGUI["config.yaml"]			
	
	dir = File.dirname __FILE__
	sr = Scope[Engine::StaticResource]
	CORE_IMPORT_SCRIPTS = ["dojo/dojo.js", "wgui/wgui.js"]
	sr.add_path CONFIG[:dojo]
	if $debug		
		sr.add_file "wgui/wgui.js", "#{dir}/data/wgui.js" 			
	else		
		sr.add_file "wgui/wgui.js", "#{dir}/data/wgui.js.gz"
		sr.add_file "dojo/dojo.js", "#{dir}/data/dojo.js.gz"		
	end
	
	sr.add_file "wgui/loading.gif", "#{dir}/data/loading.gif"	
	CONFIG[:paths].each{|path| sr.add_path path}
	
	# Need this becouse of concurrent loading it will be loaded not properly.
	WGUI::Core::IO::FileWrapper
end

# Handy Methods
module WGUI
	class << self
		def static_resource_uri path
			Engine::State::URIBuilder.static_resource_uri path
		end
		
		def resource_uri component_id
			Engine::State::URIBuilder.resource_uri component_id
		end
	end
end

# Handy Scope
module WGUI      
	Runner = Engine::Runner
	Wiget = Core::Wiget
	WigetContainer = Core::WigetContainer
	
	Button, LinkButton, Checkbox, Label, Link, Multiselect, Radiobutton, Select, TextArea, TextField, WResource,
	WImage, FileUpload, WComponent, WPortlet, WContinuation =
	
	Wigets::Button, Wigets::LinkButton, Wigets::Checkbox, Wigets::Label, Wigets::Link, Wigets::Multiselect,	 
	Wigets::Radiobutton, Wigets::Select, Wigets::TextArea, Wigets::TextField, Wigets::WResource,
	Wigets::WImage, Wigets::FileUpload, Core::WComponent, Core::WPortlet, Core::WContinuation        
end

WButton, WLinkButton, WCheckbox, WLabel, WLink, WMultiselect, WRadiobutton, WSelect, WTextArea, WTextField, 
WResource, WResourceData,	WImage, WFileUpload, WComponent, WPortlet, WContinuation =

WGUI::Wigets::Button, WGUI::Wigets::LinkButton, WGUI::Wigets::Checkbox, WGUI::Wigets::Label, WGUI::Wigets::Link, 
WGUI::Wigets::Multiselect, WGUI::Wigets::Radiobutton, WGUI::Wigets::Select, WGUI::Wigets::TextArea,
WGUI::Wigets::TextField, WGUI::Wigets::WResource, WGUI::Core::IO::ResourceData, WGUI::Wigets::WImage, WGUI::Wigets::FileUpload, 
WGUI::Core::WComponent, WGUI::Core::WPortlet, WGUI::Core::WContinuation

# Cache
require 'WGUI/Engine/cache'