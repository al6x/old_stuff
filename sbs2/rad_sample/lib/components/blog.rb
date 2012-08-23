class Rad::Blog
  attr_accessor :collection_limit
  attr_required :collection_limit
end

rad.register :blog, depends_on: [:web, :common_interface, :models] do  
  rad.configure :web, "#{__FILE__}/../../.." do |c|
    c.routes
    c.locales
    c.template_paths 'app/views'
    c.asset_paths 'app/static'
    c.autoload_paths %w(app)
  end

  Rad::Blog.new
end