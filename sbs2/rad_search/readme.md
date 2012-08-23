# Search support for Rad Kit Framework (via Apache Solr)

**Not finished and not ready to use.**


# TODO

## 1
routes.rb

module Bag
  url_root = rad.config.bag!.url_root!
  
  rad.router.configure do |c|  
    c.persistent_params :l, :space, :theme
  
    c.skip(/^#{rad.config.url_root!}\/(favicon|fs|packaged)/)
    c.skip(/^#{rad.config.url_root!}\/[^\/]+\/static\//)
        
    c.with_options url_root: url_root, prefix: :space do |c|      
      c.resource :searches, class: Searches
      c.alias '/search', class: Searches, method: :search
    end
  end
end