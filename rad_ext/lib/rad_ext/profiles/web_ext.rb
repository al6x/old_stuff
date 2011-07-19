# 
# Router
# 
rad.router.routers = [
  [:alias_router, Rad::Router::AliasRouter.new],
  [:basic_router, Rad::Router::BasicRouter.new],    
  [:restful_router, Rad::Router::RestfulRouter.new],
  [:object_router, Rad::Router::ObjectRouter.new]
]


# 
# Conveyors
# 
rad.conveyors.web do |web|
  # conveyor      
  web.use Rad::Conveyors::Processors::ConveyorLogger

  # http      
  web.use Rad::Http::Processors::HttpWriter
  web.use Rad::Http::Processors::PrepareParams
  web.use Rad::Http::Processors::EvaluateFormat
  web.use Rad::Http::Processors::HttpLogger

  # forgery protection
  web.use Rad::Processors::PrepareAutenticityToken

  # ensure no www
  web.use Rad::Processors::EnsureNoWww

  # ajax
  web.use Rad::Processors::AjaxHelper

  # html
  # web.use ScopedParams
  web.use Rad::Html::Processors::PrepareFlash

  # controller
  web.use Rad::Controller::Processors::ControllerErrorHandling

  # router
  web.use Rad::Router::Processors::Router, :class, :method_name

  # controller      
  web.use Rad::Controller::Processors::ControllerLogger
  web.use Rad::Controller::Processors::ControllerCaller

  web.build!
end


# 
# RackAdapter
# 
rad.http.stack.push(-> builder {
  # CommonLogger, ShowExceptions, Lint
  builder.use Rack::Lint if rad.development?
  
  # Static Files
  if rad.http.static? and rad.http.public_path and rad.development?
    filters = /^\/.*?\/static\/|^\/static\/|\/favicon/
    builder.use Rad::Assets::StaticFiles, filters
  end

  # use Rack::Session::Cookie, key: 'rack.session', domain: 'foo.com', path: '/', expire_after: 2592000, secret: 'change_me'  
  builder.use Rack::Session::Cookie, rad.http.session.stringify_keys if rad.http.session

  # builder.use Rack::CommonLogger
  builder.use Rack::MethodOverride
})