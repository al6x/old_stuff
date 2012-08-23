rad.router.configure do |c|
  c.alias '/ci_demo',      class_name: 'Rad::Face::Demo::Helps', method: :index
  
  c.resource :ci_helps,    class_name: 'Rad::Face::Demo::Helps'
  c.resource :ci_elements, class_name: 'Rad::Face::Demo::Commons'  
  c.resource :ci_dialogs,  class_name: 'Rad::Face::Demo::Dialogs'
  c.resource :ci_sites,    class_name: 'Rad::Face::Demo::Sites'                
end