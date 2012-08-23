class Rad::Router
  attr_accessor :routers, :formatter

  # Configuration.
  attr_accessor :default_path, :default_method, :default_format, :root
  attr_required :default_path, :default_method, :default_format, :root

  def initialize *routers
    self.routers = routers
  end

  def decode path, params
    klass, method = nil
    params = params.clone

    # Removing root.
    path = if root
      raise "invalid root for #{path} route!" unless path.start_with? root
      path.sub root, ''
    end

    # Parsing format.
    path, params = formatter.decode! path, params if formatter

    # Decoding route.
    routers.each do |router|
      result = router.decode! path, params
      if result
        klass, method, path, params = result
        break
      end
    end

    if klass
      method ||= default_method
      method.must.be_a Symbol
    end

    return klass, method, path, params
  end

  def encode klass, method, params
    klass.must.be_defined
    method.must.be_a Symbol
    params = params.clone

    path = nil
    routers.each do |router|
      path, params = router.encode! klass, method, params
      break if path
    end

    return nil unless path

    path = root + path if root

    path, params = formatter.encode! path, params if formatter

    return path, params
  end

  def configure &block
    @configurator ||= Rad::Router::Configurator.new self
    block.call @configurator
  end

end