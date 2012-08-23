rad.register :kit, depends_on: [:web, :assets, :common_interface, :models] do
  require 'kit/kit'

  rad.router.default_url = '/'
  (rad.face.availiable_layouts[:default] ||= []) << :default

  rad.configure :web, "#{__FILE__}/../../.." do |c|
    c.routes
    c.locales
    c.template_paths 'app/views'
    c.asset_paths 'app/static'
    c.autoload_paths 'app'
  end

  Rad::Kit.new
end