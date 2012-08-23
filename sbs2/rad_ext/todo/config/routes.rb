# url_root = rad.config.kit.url_root('/kit')

persistent_params = rad.extension(:persistent_params){[]}
options = rad.extension(:routes_options){{}}

url_root = rad.http.url_root
rad.router.configure do |c|
  c.persistent_params persistent_params + [:l, :theme]

  c.skip(/^#{url_root}\/?(favicon|fs|packaged)/)
  c.skip(/^#{url_root}\/?[^\/]+\/static\//)

  c.alias url_root, class_name: 'Controllers::Items', method: :redirect

  options[:url_root] ||= url_root
  c.with_options options do |c|
    # c.resource :comments,     class_name: 'Controllers::Comments'
    # c.resource :items,        class_name: 'Controllers::Items'


    #
    # Special polymorphic routes
    #
    id_to_class = rad.extension :kit_id_to_class do
      cache = {}
      -> id, params {
        model = Models::Item.by_param! id
        rad.workspace.model = model
        unless controller_class = cache[model.class]
          controller_class = "Controllers::#{model.class.alias.pluralize}".constantize
          cache[model.class] = controller_class
        end
        controller_class
      }
    end

    c.objects(
      default_class_name: 'Controllers::Items',
      class_to_resource: -> klass    {klass.alias},
      resource_to_class: -> resource {"Controllers::#{resource}".constantize},
      id_to_class:       id_to_class
    )
  end
end