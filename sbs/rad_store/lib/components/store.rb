class Rad::Store
  attr_writer :order_processing_email
  def order_processing_email; @order_processing_email || raise("key store.order_processing_email not defined!") end
  attr_accessor :currency
end

rad.register :store, depends_on: [:kit, :users] do
  require 'store/gems'
  
  rad.configure :web, "#{__FILE__}/../../.." do |c|
    c.routes
    c.locales
    c.asset_paths 'app/static'
    c.template_paths 'app/views'
    c.autoload_paths %w(lib app)
  end
  
  # config
  rad.kit.items.push(:product).uniq!

  Rad::Store.new
end