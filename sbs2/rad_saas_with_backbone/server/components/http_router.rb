rad.register :http_router do
  router = Rad::Http::Router.new
  router.routers = [
    Rad::Router::AliasRouter.new,
    Rad::Router::ResourceRouter.new,
    Rad::Router::CustomRouter.new
  ]
  router.formatter = Rad::Router::DotFormat.new
  router.root = rad.http.root
  router
end