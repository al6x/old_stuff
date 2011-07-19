%w(
  configurators
  extensions
  protect_from_forgery
).each{|f| require "rad_ext/#{f}"}