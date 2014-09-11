module WGUI
	Core::Wiget	
	class Core::Wiget
		def new klass, parameters
			WGUIExt::View.create_wiget klass, parameters
		end
	end
	
	WGUI::Utils::TemplateHelper.custom_template = lambda do |klass, resource|
		skin = Scope[::ActivePoint::WebClient::Client].skin		
		return nil unless skin and !skin.empty?
		
		resource = "#{klass.name.gsub("::", "/")}.#{resource}"
		dir = ::ActivePoint::CONFIG[:skins_directory]
		
		file = File.join dir, skin, resource
		if File.exist? file
			return File.read(file)
		else
			nil
		end
	end
end	