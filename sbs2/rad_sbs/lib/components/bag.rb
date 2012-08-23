class Rad::Bag
end

rad.register :bag, depends_on: [:kit, :users] do
  require 'sbs/gems'

  rad.configure :web, "#{__FILE__}/../../.." do |c|
    # c.config blank: true, override: false
    c.routes
    c.locales
    c.template_paths 'app/views'
    c.asset_paths 'app/static'
    c.autoload_paths %w(lib app)
  end

  # config
  rad.kit.items.push(:note, :selector).uniq!

  Rad::Bag.new
end