class Object
  def to_l string, binding = nil
		unless RubyExt::Localization.language == RubyExt::Localization::DEFAULT_LANGUAGE
      localization = self.class.localization RubyExt::Localization.language
      if localization
        if localization.include? string
          string = localization[string]
        else
          name = (self == Class or self == Module) ? self.name : self.class.name
          RubyExt::Localization.log.warn("Not localized: '#{name}' '#{string}'!")
        end
      end
		end
		
		string = string.substitute binding if binding
		return string
	end
end