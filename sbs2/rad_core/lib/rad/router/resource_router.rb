# Similar to Rails restful routes, usage:
# - "/resource_name/method?params" <=> [class, method, params]
# - "/resource_name/id/method?params" <=> [class, method, params_with_id]
#
# It also support prefixes, like this:
# - "/en/resource_name/method?params" <=> [class, method, params_with_language]
class Rad::Router::ResourceRouter
  include Rad::Router::RouterHelper

  attr_accessor :default_singleton_method, :default_singleton_methods, :default_method

  def initialize
    @default_singleton_method, @default_method = :all, :read
    @default_singleton_methods = [:all, :create]
    @resources, @class_names = {}, {}
  end

  def add resource, options = {}
    options.validate_options! :class_name, :prefix, :singleton_methods
    resource = resource.to_sym.must_not =~ /\// if resource
    class_name = options[:class_name] || raise("no class name!")

    resources.must_not.include(resource)
    class_names.must_not.include(class_name)

    meta = {
      class_name:        class_name,
      resource:          resource,
      prefix:            parse_prefix(options),
      singleton_methods: (options[:singleton_methods] || default_singleton_methods)
    }
    resources[resource] = meta
    class_names[class_name] = meta
  end

  def encode! klass, method, params
    meta = class_names[klass.name]
    return nil unless meta
    resource = meta[:resource]

    path = if id = params.delete(:id)
      id = id.to_s.uri_escape
      method ||= default_method
      method == default_method ? "/#{id}" : "/#{id}/#{method}"
    else
      method ||= default_singleton_method

      msg = "there's no :#{method} method in the list of singleton methods for :#{resource} resource!"
      raise msg unless meta[:singleton_methods].include?(method)

      method == default_singleton_method ? '' : "/#{method}"
    end

    path = "/#{resource}#{path}" if resource

    prefix = meta[:prefix]
    path, params = encode_prefix_params! path, params, prefix if prefix

    [path, params]
  end

  def decode! path, params
    decode_as_singleton_resource(path, params) || decode_as_object_resource(path, params)
  end

  protected
    attr_accessor :resources, :class_names

    def decode_as_object_resource path, params
      parts = path[1..-1].split('/')
      return nil unless parts.size >= 1

      # Checking for explicitly encoded method.
      resource, id, method = parts[-3].try(:to_sym), parts[-2], parts[-1].try(:to_sym)
      prefix = parts[0..-4]
      unless id and method and has_route_for(prefix, resource)
        # Checking for default method.
        resource, id, method = parts[-2].try(:to_sym), parts[-1], default_method
        prefix = parts[0..-3]
        return nil unless has_route_for(prefix, resource)
      end
      meta = resources[resource]

      path, params = decode_prefix_params! path, parts, params, meta[:prefix] if meta[:prefix]

      params[:id] = id

      klass = get_class meta[:class_name]

      [klass, method, path, params]
    end

    def decode_as_singleton_resource path, params
      parts = path[1..-1].split('/')
      # return nil unless parts.size >= 1

      # Checking for explicitly encoded method.
      resource, method = parts[-2].try(:to_sym), parts[-1].try(:to_sym)
      prefix = parts[0..-3]
      unless method and has_route_for(prefix, resource)
        # Checking for default method.
        resource, method = parts[-1].try(:to_sym), default_singleton_method
        prefix = parts[0..-2]
        return nil unless has_route_for(prefix, resource)
      end
      meta = resources[resource]

      return nil unless meta[:singleton_methods].include?(method)

      path, params = decode_prefix_params! path, prefix, params, meta[:prefix] if meta[:prefix]

      klass = get_class meta[:class_name]

      [klass, method, path, params]
    end

    def has_route_for prefix, resource
      meta = resources[resource]
      return false unless meta

      prefix_definition = meta[:prefix]
      return false if prefix.size != (prefix_definition ? prefix_definition.size : 0)

      true
    end
end

Rad::Router::Configurator.class_eval do
  def resource *args, &block
    router = @router.routers.find{|router| router.is_a? ::Rad::Router::ResourceRouter}
    raise "There's no #{::Rad::Router::ResourceRouter} (use config to add it)!" unless router
    router.add *args, &block
  end
end