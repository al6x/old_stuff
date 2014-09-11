module Localization
  extend Log
	DEFAULT_LANGUAGE = "en"
  RESOURCE_EXTENSION = "localization.yaml"

  class << self
    def default_language= lang
      @default_language = lang
    end

    def default_language
      @default_language ||= DEFAULT_LANGUAGE
    end

    def language= block
      @language = block
    end

    def language
      if @language
				lang = @language.call
				return lang || default_language
			else
				return default_language
			end
    end
  end
end