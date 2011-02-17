module Locale
	module ClassMethods
		def locale *args
			args.each{|attr| _locale attr}
		end
		
		protected
		def _locale attr
			attr.should! :be_a, Symbol
			self.instance_methods.should! :include, attr.to_s
			
			alias_method :"locale_#{attr}", attr
			alias_method :"locale_#{attr}=", :"#{attr}="
			
			script = %{\
def #{attr}
	_locale_get :#{attr}
end			

def #{attr}= value
	_locale_set :#{attr}, value
end}

			self.class_eval script, __FILE__, __LINE__
		end
	end
	
	class << self
		def language lang = :en, &b
			begin
				Thread.current[:explicit_language] = lang
				b.call
			ensure
				Thread.current[:explicit_language] = nil
			end			
		end
	end
	
	def _locale_get attr		
		values = send :"locale_#{attr}"
		lang = Thread.current[:explicit_language] || RubyExt::Localization.language
		locale = values[lang]
		if locale
			locale
		elsif default_locale = values[RubyExt::Localization.default_language]
			default_locale
		else
			ameta = self.meta.attributes[attr]
			type = Metadata::ATTRIBUTE_TYPES_SHORTCUTS[ameta.parameters[:type]]
			type.initial_value ameta, self
		end
	end
	
	def _locale_set attr, value
		ameta = self.meta.attributes[attr]
		type = Metadata::ATTRIBUTE_TYPES_SHORTCUTS[ameta.parameters[:type]]
		type.validate_type value
		
		values = send(:"locale_#{attr}").dup		
		lang = Thread.current[:explicit_language] || RubyExt::Localization.language
		values[lang] = value
		send :"locale_#{attr}=", values
	end
end