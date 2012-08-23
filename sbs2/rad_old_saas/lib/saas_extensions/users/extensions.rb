%w(
  models
  controllers
).each{|f| require "saas_extensions/users/#{f}"}

fixme
I18n.load_path += Dir["#{__FILE__.dirname}/locales/**/*.{rb,yml}"]