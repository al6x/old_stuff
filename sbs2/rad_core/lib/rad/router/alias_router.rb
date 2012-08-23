class Rad::Router::AliasRouter
  include Rad::Router::RouterHelper

  class TreeHash < Hash
    attr_accessor :meta
  end

  def initialize
    @route_methods, @paths, @classes = {}, TreeHash.new, {}
  end

  def add als, options = {}
    options.validate_options! :class_name, :method, :prefix

    als = als.to_s
    als.must =~ /^\//
    class_name = options.delete(:class_name) || raise("no class name!")
    class_name.must.be_a String
    method = options.delete(:method) || raise("no method!")
    method = method.must.be_a Symbol
    prefix = parse_prefix options

    # logic
    meta = {class_name: class_name, method: method, path: als, prefix: prefix}

    route_methods["#{als[1..-1]}_path"] = meta

    (classes[class_name] ||= {})[method] = meta


    parts = als[1..-1].split('/')
    parts << '' if parts.empty?

    tree_iterator = paths
    parts.reverse.each do |part|
      tree_iterator = (tree_iterator[part] ||= TreeHash.new)
      raise "alias '#{als}' conflicted with another alias ('#{tree_iterator.meta[:path]}')!" if tree_iterator.meta
    end
    tree_iterator.meta = meta
  end

  def encode! klass, method, params
    if meta = classes[klass.name].try(:[], method)
      path = meta[:path]

      prefix = meta[:prefix]
      path, params = encode_prefix_params! path, params, prefix if prefix

      return path, params
    else
      nil
    end
  end

  def decode! path, params
    parts = path[1..-1].split('/')
    parts << '' if parts.empty?

    tree_iterator = paths

    # checking for first part
    part = parts.pop
    tree_iterator = tree_iterator[part]
    return nil unless tree_iterator

    # checking for exact match
    while part = parts.pop
      tmp = tree_iterator[part]
      unless tmp
        parts << part
        break
      end
      tree_iterator = tmp
    end

    meta = tree_iterator.meta

    # prefix
    prefix = meta[:prefix]
    path, params = decode_prefix_params! path, parts, params, prefix if prefix

    klass = get_class meta[:class_name]

    return klass, meta[:method], path, params
  end

  protected
    attr_accessor :paths, :route_methods, :classes
end


Rad::Router::Configurator.class_eval do
  def alias *args, &block
    router = @router.routers.find{|router| router.is_a? Rad::Router::AliasRouter}
    raise "There's no AliasRouter (use config to add it)!" unless router
    router.add *args, &block
  end
end