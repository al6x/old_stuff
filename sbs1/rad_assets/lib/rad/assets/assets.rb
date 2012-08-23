class Rad::Assets
  inject logger: :logger, environment: :environment

  #
  # Config
  #
  attr_accessor :static_path_prefix
  # attr_required :static_path_prefix


  def resolve_http_paths http_path
    resource = pack? ? Rad::Assets::PackagedResource.new(http_path) : Rad::Assets::Resource.new(http_path)
    resource.resolved_http_paths
  end
  cache_method_with_params_in_production :resolve_http_paths

  def paths
    @paths ||= []
  end

  def copy_to_public!
    paths.each do |path|
      path = path.to_dir
      raise "asset path should exist (#{path})!" unless path.exist?
      raise "asset path should be a directory (#{path})!" unless path.dir?
      path.copy_to "#{rad.http.public_path}#{static_path_prefix}".to_dir
    end
  end

  def fs_path http_path
    http_path.must =~ /^\//
    environment.find_file http_path, paths
  end

  def asset? http_path
    !!((http_path =~ /^\//) and fs_path(http_path))
  end
  cache_method_with_params_in_production :asset?

  protected
    def pack?
      rad.production?
    end
end