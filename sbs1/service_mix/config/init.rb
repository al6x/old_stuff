require 'rad'

# localization
I18n.default_locale = :en

# 
# Assembling plugins
# 
crystal.initialize_plugin :app, __FILE__.parent_dirname do |c|
  c.plugins %w(users admin)
end