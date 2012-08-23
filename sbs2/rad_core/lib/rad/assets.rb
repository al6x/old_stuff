class Rad::Assets
  inject :logger, :environment, :http

  attr_accessor :prefix, :build_prefix, :package_prefix, :paths

  def initialize
    @paths = []
  end

  def get *paths
    cache = {}
    paths.collect do |path|
      get_resource(path, cache).resolved_paths
    end.flatten
  end
  cache_method_with_params_in_production :get

  def copy_to_public!
    paths.each do |path|
      path = path.to_dir
      raise "assets path should exist (#{path})!" unless path.exist?
      raise "assets path should be a directory (#{path})!" unless path.dir?
      path.copy_to "#{http.public_path}#{http.root}#{prefix}".to_dir
    end
  end

  def fs_path path
    path.must =~ /^\//
    paths = self.paths + [http.public_path + http.root + prefix]
    environment.find_file path, paths
  end

  def pack?; rad.production? end

  def get_resource path, cache = {}
    if cache.include? path
      cache[path]
    else
      klass = get_resource_class path.to_file.extension
      resource = klass.new path, cache
      cache[path] = resource
    end
  end

  module Middleware
  end

  protected
    def get_resource_class extension
      begin
        Rad::Assets::Resources.const_get extension.camelize
      rescue
        raise "can't load resource class #{Rad::Assets::Resources}::#{extension.camelize} for #{extension} extension!"
      end
    end
    cache_method_with_params :get_resource_class
end