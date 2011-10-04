class Localization
	extend Configurator
	
	def languages
		CONFIG[:languages]
	end
	
	def language= lang
		lang.should! :be_in, languages
		Scope[:language] = lang
		Scope[WGUI::Engine::Window].refresh_all
	end
	
	def language
		Scope[:language]
	end
	
	startup do
		Scope.register :language, :session do
			CONFIG[:default_language]
		end
		
		::RubyExt::Localization.language = lambda do 
			Scope.active?(:session) ? Scope[:language] : nil
		end		
		::RubyExt::Localization.default_language = ActivePoint::CONFIG[:default_language]
		
		Scope[:services][:localization] = Localization.new
	end
end