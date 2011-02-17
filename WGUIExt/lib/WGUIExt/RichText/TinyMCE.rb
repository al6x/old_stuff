dir = File.dirname __FILE__
klass = WGUIExt::RichText
Scope[WGUI::Engine::StaticResource].add_file "#{klass}/file_manager.gif", "#{dir}/file_manager.gif" 
Scope[Engine::StaticResource].add_path "#{dir}/tiny_mce/jscripts"
#Scope[Engine::StaticResource].add_path CONFIG[:tinymce]

class TinyMCE < Core::InputWiget		
	extend MicroContainer::Injectable
	inject :window => Engine::Window
	
	attr_reader :text, :styles, :external_toolbar
	attr_accessor :resources
	
	def initialize text = ""
		super()
		@text, @external_toolbar = text, false         
	end
	
	def update_value value
		value = BeautifulSoup.new(value).to_s
		value = value.gsub("%nbsp", "&nbsp;")
		@text = value
	end
	
	def text= value		
		return if @text == value
		@text = value
		refresh
	end
	
	def editor_id; "editor_#{component_id}" end
		
	alias_method :old_to_html, :to_html
	def to_html
		Scope[Engine::Window].add_import_script "tiny_mce/tiny_mce.js" unless WGUI::CONFIG[:uidriver_mode]
		old_to_html
	end
end