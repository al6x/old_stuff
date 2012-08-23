module Bag
  # url_root = rad.config.bag!.url_root!
  
  rad.router.configure do |c|  
    c.persistent_params :l, :space, :theme
  
    c.skip(/^#{rad.config.url_root!}\/(favicon|fs|packaged)/)
    c.skip(/^#{rad.config.url_root!}\/[^\/]+\/static\//)
        
    c.alias rad.config.url_root!, class: Items, method: :redirect
  
    c.with_options prefix: :space do |c|
      c.resource :applications, class: ApplicationController
      
      c.resource :comments,     class: Comments
      c.resource :files,        class: Files
      c.resource :folders,      class: Folders      
      c.resource :items,        class: Items
      c.resource :lists,        class: Lists
      c.resource :notes,        class: Notes
      c.resource :pages,        class: Pages      
      c.resource :selectors,    class: Selectors
      c.resource :tasks,        class: Tasks
      
      c.resource :searches, class: Searches
      c.alias '/search', class: Searches, method: :search
    end
  end
end