require 'i18n'
require "i18n/backend/pluralization"

I18n::Backend::Simple.include I18n::Backend::Pluralization
I18n.load_path += Dir["#{__FILE__.dirname}/locale/*/*.{rb,yml}"]

class Rad::Locale
  attr_writer :available
  def available; @available ||= [] end

  attr_accessor :default
  attr_required :default

  delegate :t, to: I18n

  def paths; I18n.load_path end
  def paths= paths; I18n.load_path = paths end

  def current= lang
    I18n.locale = lang || default
  end
  def current; I18n.locale end
end