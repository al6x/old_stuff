rad.register :router do |config|
  router = Rad::Router.new
  if config
    config = config.clone

    if routers = config.delete(:routes)
      router.routers = routers.collect{|klass| klass.constantize.new}
    end

    if formatter = config.delete(:formatter)
      self.formatter = formatter.constantize.new
    end

    config.each{|key, value| router.send "#{key}=", value}
  end
  router
end

root: ''
default_path: '/'
default_method: 'call'
default_format: 'html'

routes:
- "Rad::Router::AliasRouter"
- "Rad::Router::ResourceRouter"
- "Rad::Router::ObjectRouter"
