# Ruby
require 'RubyExt/require'
require 'json'

# eRubis
require 'erubis'


# Rack
#gem 'rack', '= 0.9.1'
#warn "Old Rack version"

require 'rack'
require 'rack/lint'
#require 'rack/showexceptions.rb'
#require 'rack/session/pool.rb'
require 'rack/utils'

# RubyfulSoup
require 'rubyful_soup'
require 'rexml/document'
#require 'rexml/formatters/transitive'

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
	# Config	
	user_conf = if File.exist?("config/wgui.yaml")
		YAML.load(File.read("config/wgui.yaml"))
	else
		{}	
	end
	CONFIG = RubyExt::Config.new({}, user_conf, WGUI["config.yaml"])
	
	dir = File.dirname __FILE__
	data_dir = "#{dir}/../../data"
	sr = Scope[Engine::StaticResource]	
	CORE_IMPORT_SCRIPTS = ["dojo/dojo.js", "wgui/wgui.js"]
	sr.add_path data_dir
	if $debug		
		sr.add_file "wgui/wgui.js", "#{data_dir}/wgui/wgui.js" 			
	else		
		sr.add_file "wgui/wgui.js", "#{data_dir}/wgui/wgui.js.gz"
		sr.add_file "dojo/dojo.js", "#{data_dir}/dojo/dojo.js.gz"		
	end
	
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
		
		def rack_app *args
			Engine::BrigeServlet.new *args
		end
	end
end

# Handy Scope
module WGUI      
	Runner = Engine::Runner
	Wiget = Core::Wiget
	WigetContainer = Core::WigetContainer
	
	Button, LinkButton, Checkbox, Label, Link, Multiselect, Radiobutton, Select, TextArea, TextField, WResource,
	WImage, FileUpload, WComponent, WPortlet, WContinuation, SelectButton =
	
	Wigets::Button, Wigets::LinkButton, Wigets::Checkbox, Wigets::Label, Wigets::Link, Wigets::Multiselect,	 
	Wigets::Radiobutton, Wigets::Select, Wigets::TextArea, Wigets::TextField, Wigets::WResource,
	Wigets::WImage, Wigets::FileUpload, Core::WComponent, Core::WPortlet, Core::WContinuation,
	Wigets::SelectButton
end

WButton, WLinkButton, WCheckbox, WLabel, WLink, WMultiselect, WRadiobutton, WSelect, WTextArea, WTextField, 
WResource, WResourceData,	WImage, WFileUpload, WComponent, WPortlet, WContinuation, WSelectButton =

WGUI::Wigets::Button, WGUI::Wigets::LinkButton, WGUI::Wigets::Checkbox, WGUI::Wigets::Label, WGUI::Wigets::Link, 
WGUI::Wigets::Multiselect, WGUI::Wigets::Radiobutton, WGUI::Wigets::Select, WGUI::Wigets::TextArea,
WGUI::Wigets::TextField, WGUI::Wigets::WResource, WGUI::Core::IO::ResourceData, WGUI::Wigets::WImage, WGUI::Wigets::FileUpload, 
WGUI::Core::WComponent, WGUI::Core::WPortlet, WGUI::Core::WContinuation, WGUI::Wigets::SelectButton

# Cache
require 'WGUI/Engine/cache'