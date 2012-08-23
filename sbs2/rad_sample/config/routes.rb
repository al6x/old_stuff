rad.router.configure do |c|
  c.persistent_params :l
  
  c.skip(/^\/favicon/)
  
  c.redirect(/^\/$/, "/Posts")
  
  # Polymorphic route
  # it's ok that it's so complicated, there's only one 
  # such a route for the whole application.
  cache = {}    
  c.objects(
    default_class_name: 'Controllers::Nodes',
    class_to_resource: -> klass {klass.alias},
    resource_to_class: -> resource {"Controllers::#{resource}".constantize},    
    id_to_class:       -> id, params {
      model = Models::Node.by_param! id
      rad.workspace.model = model
      unless controller_class = cache[model.class]
        controller_class = "Controllers::#{model.class.alias.pluralize}".constantize
        cache[model.class] = controller_class
      end
      controller_class
    }
  )  
end