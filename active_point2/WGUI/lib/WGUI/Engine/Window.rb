class Window < Core::Wiget
	include Core::WigetContainer
	extend Managed
	
	scope :session
	
	inject :brige_servlet => BrigeServlet
	
	attr_accessor :title, :css_list, :favicon, :language, :session_id
	children :content
	
	def content
		Scope[brige_servlet.app_class]
	end
	
	def initialize title = ''		
		@title = title
		self.language = CONFIG[:default_language]
	end	
	
	def to_html; 
		Utils::TemplateHelper.render_template  self.class, :binding => binding
	end
	
#	def skin
#		@skin ||= CONFIG[:default_skin]
#	end
	
	def add_style style
		@styles << style
	end
	
	def styles_get
		@styles
	end
	
	def styles_set value
		@styles = value
	end
	
	def add_import_script script
		@import_scripts << script unless @import_scripts.include? script
	end
	
	def import_scripts_get
		@import_scripts
	end
	
	def import_scripts_set value
		@import_scripts = value
	end
	
	def refresh_all
		content.visit Visitors::RefreshAll if content
	end
end