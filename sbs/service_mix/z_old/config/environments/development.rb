# 
# Standart rails setting
# 

# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false



# 
# ServiceMix <-> App proxy and static files middleware
# 
prefix = config.action_controller.relative_url_root

# Needed in development to proxy requests to real application (real application can't be used to proxy requests to ServiceMix, 
# becouse it causes deadlocks)
require 'middleware/proxy'
config.middleware.insert 0, Middleware::Proxy do |req|
  if (path = req.path) !~ /\A#{prefix}\//
    query = req.query_string
    URI.parse("http://localhost:3001#{path}#{"?#{query}" unless query.blank?  }")
  end
end

# Rails doesn't understand "config.action_controller.relative_url_root = "/service_mix"" for asset, 
# so we need custom rewriter for assets (in production it doesn't needed, assets served by nginx)
# And one more problem, we can't delete Rails::Rack::Static from middleware stack, so we hack it.
require 'middleware/static_files_hack'
Rails::Rack::Static.prefix = prefix


# 
# Others
# 

config.gem "factory_girl"

# Redirect uses these parametres and causes localhost:3000 => localhost:3001
# ActionController::Base.default_url_options[:host]
# ActionController::Base.default_url_options[:port] = 3000

# Synthesis::AssetPackage.merge_environments << 'development'

# Disable partial logging
ActionView::RenderablePartial.send :class_eval do
  def render(view, local_assigns = {})
    super
  end
end