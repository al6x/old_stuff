# RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION
# 
# require File.join(File.dirname(__FILE__), 'boot')
# 
# Rails::Initializer.run do |config|
#   # Activate observers that should always be running
#   # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
# 
#   config.frameworks -= [:active_record]

  config.time_zone = 'UTC'
    
# # %w{cross_domain_cookies}.each{|f| require "vendor/plugins/sm_commons/lib/sm_commons/middleware/#{f}"}
# # config.middleware.insert 0, Middleware::CrossDomainCookies
# # Upload files with flash
# # require 'middleware/flash_session_cookie_middleware'
# # config.middleware.insert 0, Middleware::FlashSessionCookieMiddleware  
# # require 'middleware/cross_site_method_override'
# # config.middleware.swap Rack::MethodOverride, Middleware::CrossSiteMethodOverride
  
  config.action_controller.relative_url_root = "/sm"
  
  # config.i18n.default_locale = :ru
  # config.i18n.load_path += Dir["#{RAILS_ROOT}/app/locales/**/*.{rb,yml}"]
  
  # config.gem 'rails-ext', :lib => 'rails_ext/asset_packager'
  # config.gem 'rails-ext', :lib => 'rails_ext/active_support'
  # config.gem 'rails-ext', :lib => 'rails_ext/action_controller'
  # config.gem 'rails-ext', :lib => 'rails_ext/action_view'
  # config.gem 'rails-ext', :lib => 'rails_ext/micelaneous'
  # 
  # config.gem 'addressable', :lib => 'addressable/uri'

  config.gem 'ruby-openid', :lib => 'openid'
  config.gem 'rack-openid', :lib => 'rack/openid'
  config.gem 'rest-client', :lib => 'rest_client'
  config.gem "json"
  # config.gem "mongo_mapper"
  config.gem 'paperclip'
  config.gem 'haml'
  config.gem 'state_machine'
  
  config.gem 'bluecloth'
  config.gem 'sanitize'
  config.gem 'stringex'
  
  config.plugins = [ 
    :sm_commons, 

    :all 
  ]
  
end