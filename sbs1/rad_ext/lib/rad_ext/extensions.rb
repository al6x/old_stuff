require 'rad'

%w(
  i18n
  prepare_model
  user_error
).each{|f| require "rad_ext/extensions/#{f}"}