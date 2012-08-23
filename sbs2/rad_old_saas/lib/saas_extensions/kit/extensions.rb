#
# Controllers
#
require 'saas/_controller/multitenant'

rad.register_extension :kit_app do
  inherit Rad::Controller::Multitenant
end


#
# Mongoid
#
rad.register_extension :model_authorization do
  require 'saas/_models/space_attribute'

  inherit Models::SpaceAttribute

  space_attribute :roles, default: [], standalone: []
  alias_method :mm_roles,  :roles
  alias_method :mm_roles=, :roles=

  space_attribute :admin, default: false, standalone: false

  attr_accessor :global_admin

  alias_method :admin_without_ga, :admin
  define_method :admin do
    admin_without_ga or global_admin
  end
end

rad.register_extension :mm_extensions do
  require 'saas/_models/multitenant'
  Mongo::Model.inherit Models::Multitenant
end


#
# Models
#
# rad.register_extension :secure_token do
#   db :global
# end

rad.register_extension :item_model do
  belongs_to_space
end

rad.register_extension :item_slug do
  create_index [[:space_id, 1], [:slug, 1]], unique: true
end

rad.register_extension :tag_model do
  create_index [[:space_id, 1], [:name, 1]], unique: true
  belongs_to_space
end

rad.register_extension :attachment_file_path do
  define_method :build_path do |*args|
    "#{rad.models.fs['prefix']}/#{rad.account._id}/#{rad.space._id}/#{model_id}" + build_standard_path(*args)
  end

  define_method :build_url do |*args|
    "#{rad.models.fs['host']}#{rad.models.fs['prefix']}/#{rad.account._id}/#{rad.space._id}/#{model_id}" + build_standard_url(*args)
  end
end


#
# Routes
#
rad.register_extension(:persistent_params){[:space]}
rad.register_extension(:routes_options){{prefix: :space}}

rad.register_extension :kit_id_to_class do
  # We need to know Account and Space before we are starting to search for Item
  cache = {}
  id_to_class = -> id, params {
    # preparing account and space, we need it to search for item from this space
    Rad::Controller::Multitenant.prepare_multitenant_account
    Rad::Controller::Multitenant.prepare_multitenant_space params

    # searching item
    model = Models::Item.by_param! id
    rad.workspace.model = model
    unless controller_class = cache[model.class]
      controller_class = "Controllers::#{model.class.alias.pluralize}".constantize
      cache[model.class] = controller_class
    end
    controller_class
  }

  # ensurance that Account and Space always will be properly cleaned
  # rad.router
  Rad::Router::Processors::Router.class_eval do
    raise "Can't be applied twice!" if self.method_defined?(:call_without_ensurance)

    alias_method :call_without_ensurance, :call
    def call
      begin
        call_without_ensurance
      ensure
        rad.delete :account
        rad.delete :space
      end
    end
  end

  id_to_class
end


#
# User Menu
#
rad.register_extension :user_menu do |a|
  rad.logger.info account: rad.account?, can: can?(:administration)
  if rad.account? and can?(:administration)
    url = url_for(
      "/#{rad.account.name}/spaces/all",
      url_root: rad.saas.url_root
      # , host: rad.saas.host, port: rad.saas.port
    )
    a.add link_to(t(:administration), url)
  end
end