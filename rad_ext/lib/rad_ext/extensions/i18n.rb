# Hack, ActiveSupport currently uses differrent version
# gem 'i18n', '>= 0.4.1'
# require 'i18n'

require "i18n/backend/pluralization" 
I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

I18n.load_path += Dir["#{__FILE__.dirname}/i18n/locales/*/*.{rb,yml}"]


# 
# Helpers for Rad
# 
[Rad::Controller::Abstract, Rad::Controller::Context].each do |klass|
  klass.delegate :t, to: I18n
end