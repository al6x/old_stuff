class Rad::Router::ObjectRouter
  include Rad::Router::RouterHelper

  def initialize
    self.class_to_resource = -> klass      {raise ':class_to_resource not specified!'}
    self.resource_to_class = -> resource   {raise ':resource_to_class not specified!'}
    self.id_to_class       = -> id, params {raise ':id_to_class not specified!'}

    self.default_class_method  = :all
    self.default_method = :read

    @cached_class_to_resource, @cached_resource_to_class = {}, {}
  end

  def configure options = {}
    raise "can't configure ObjectRouter twice!" if configured?
    self.configured = true

    # parsing options
    options.validate_options! :default_class_name, :class_to_resource, :resource_to_class, :id_to_class, :prefix

    self.default_class_name = options[:default_class_name] || raise(':default_class_name not provided!')

    self.class_to_resource = options[:class_to_resource] if options.include? :class_to_resource
    self.resource_to_class = options[:resource_to_class] if options.include? :resource_to_class
    self.id_to_class       = options[:id_to_class]       if options.include? :id_to_class

    self.prefix = parse_prefix options
  end

  def encode! klass, method, params
    return nil unless configured?

    id = params[:id]

    # id and resource
    path = if id
      raise ":id can be used with :default_class only (#{klass}, '#{id}')!" if klass != default_class

      params.delete :id
      raise ":id must not start from capital letter ('#{id}')!" if id =~ /^[A-Z]/

      path = if !method or method == default_method
        "/#{id}"
      else
        "/#{id}/#{method}"
      end
    else
      resource = cached_class_to_resource klass
      raise "no resource for #{klass}!" unless resource
      raise "resource must start from capital letter (class: #{klass}, resource: '#{resource}')!" unless resource =~ /^[A-Z]/

      path = if !method or method == default_class_method
        "/#{resource}"
      else
        "/#{resource}/#{method}"
      end
    end

    # prefix
    path, params = encode_prefix_params! path, params, prefix if prefix

    [path, params]
  end

  def decode! path, params
    return nil unless configured?

    parts = path[1..-1].split('/')

    # checking 'size' of path
    extra_size = (prefix ? prefix.size : 0)
    valid_range = (1 + extra_size)..(2 + extra_size)
    raise "invalid 'size' of path, must be in #{valid_range}!" unless valid_range.include? parts.size

    # prefix
    path, params = decode_prefix_params! path, parts, params, prefix if prefix

    # id, resource and method
    if parts.first =~ /^[A-Z]/
      resource, method = parts
      method ||= default_class_method
      method = method.to_sym

      # raise "resource must be in plural form ('#{resource}')!" unless resource.pluralize == resource

      klass = cached_resource_to_class resource

      raise "no class for '#{resource}' resource!" unless klass
    else
      id, method = parts

      method ||= default_method
      method = method.to_sym

      # sometimes we need params inside of :id_to_class block,
      # for example to find out Space before finding Item
      klass = id_to_class.call id, params

      raise "no class for '#{id}' id!" unless klass

      params[:id] = id
    end

    klass.must.be_a Class
    return klass, method, path, params
  end

  protected
    attr_accessor :class_to_resource, :resource_to_class, :id_to_class, :default_class_method, :default_method,
      :prefix, :configured, :default_class_name

    def default_class
      @default_class ||= default_class_name.constantize
    end

    def configured?; !!@configured end

    def cached_class_to_resource klass
      unless @cached_class_to_resource.include? klass
        resource = class_to_resource.call klass
        resource.must_not =~ /\//
        # raise 'resource name must be in plural form' unless resource.pluralize == resource
        @cached_class_to_resource[klass] = resource
      end
      @cached_class_to_resource[klass]
    end

    def cached_resource_to_class resource
      unless @cached_resource_to_class.include? resource
        klass = resource_to_class.call resource
        @cached_resource_to_class[resource] = klass
      end
      @cached_resource_to_class[resource]
    end
end


Rad::Router::Configurator.class_eval do
  def objects *args, &block
    router = @router.routers.find{|router| router.is_a? Rad::Router::ObjectRouter}
    raise "There's no ObjectRouter (use config to add it)!" unless router
    router.configure *args, &block
  end
end