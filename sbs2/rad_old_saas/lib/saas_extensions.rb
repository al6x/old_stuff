require 'rad'

%w(
  saas
  kit
  users
).each{|f| require "saas_extensions/#{f}/extensions"}

warn '  RAD SaaS extensions applied'