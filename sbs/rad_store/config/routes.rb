# options = rad.extension(:routes_options){{}}
# 
# rad.router.configure do |c|  
#   options[:url_root] ||= rad.config.url_root!
#   
#   c.with_options options do |c|
#     c.resource :identities, class_name: 'Controllers::Identities'
#   end
# end