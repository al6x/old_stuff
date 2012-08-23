rad.router.configure do |c|
  c.resource :ci_objects,  class_name: 'Rad::Face::Demo::Objects'
  c.resource :ci_stores,   class_name: 'Rad::Face::Demo::Stores'
end