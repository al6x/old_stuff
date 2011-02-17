module WGUI
	# Wiget
	Core::Wiget	
	class Core::Wiget
		def new klass, parameters
			WGUIExt::Form.create_wiget klass, parameters
		end
	end		
	
	# TemplateHelper
	Utils::TemplateHelper
	class Utils::TemplateHelper
		class << self
			alias :generate_template_id_original :generate_template_id
			def generate_template_id klass, resource
				skin = Scope[::ActivePoint::Adapters::Web::App].skin		
				_generate_template_id klass, resource, skin
			end
			
			alias :read_template_original :read_template
			def read_template klass, resource
				skin = Scope[::ActivePoint::Adapters::Web::App].skin		
				return read_template_original klass, resource unless skin and !skin.empty?
				
				resource_path = "#{klass.name.gsub("::", "/")}.#{resource}"
				dir = ::ActivePoint::CONFIG[:skins_directory]
				
				file = File.join dir, skin, resource_path
				if File.exist? file
					return File.read(file)
				else
					return read_template_original klass, resource
				end
			end
			
			def _generate_template_id klass, resource, skin
				return generate_template_id_original klass, resource unless skin and !skin.empty?
				
				resource_path = "#{klass.name.gsub("::", "/")}.#{resource}"
				dir = ::ActivePoint::CONFIG[:skins_directory]
				
				file = File.join dir, skin, resource_path
				if File.exist? file
					return "#{skin}/#{klass.name}/#{resource}"
				else
					return generate_template_id_original klass, resource
				end
			end
		end
	end
	
	
	#	Utils::TemplateHelper.custom_template = lambda do |klass, resource|						
	#		skin = Scope[::ActivePoint::Adapters::Web::Client].skin		
	#		return super unless skin and !skin.empty?
	#		
	#		resource = "#{klass.name.gsub("::", "/")}.#{resource}"
	#		dir = ::ActivePoint::CONFIG[:skins_directory]
	#		
	#		file = File.join dir, skin, resource
	#		if File.exist? file
	#			return File.read(file)
	#		else
	#			return super
	#		end
	#	end
	
	# BrigeServlet
	class BrigeServletObserver
		def post
			C.messages.clear
		end
		
		def push
			C.messages.clear
		end
	end

	Engine::BrigeServlet.exception_wrapper = lambda do |callback|
		begin
			callback.call
		rescue RuntimeError, SecurityError => e
			ActivePoint::Adapters::Web.log.error e if $debug
			C.messages.error e.message		
		end		
	end		
	Engine::BrigeServlet.add_observer BrigeServletObserver.new
	
	# Skin Static Resource
	class << self
		def skin_static_resource_uri name
			skin = Scope[ActivePoint::Adapters::Web::App].skin
			skin.should_not! :be_nil
			skin.should_not! :empty?
			return static_resource_uri "#{ActivePoint::Adapters::Web::SKINS}/#{skin}/#{name}"
		end
	end
end	