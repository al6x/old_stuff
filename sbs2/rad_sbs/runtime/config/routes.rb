# rad.router.configure do |c|
#   # redirecting namespace /blog to default url /blog/Items/redirect
#   c.redirect(/^\/([^\/]+)$/, "/\\1/Items/redirect")
#   # c.alias "/", class_name: 'Controllers::Items', method: :redirect
# end