class Rad::Assets::Resource
  attr_reader :source_path, :source_fs_path, :cache
  inject :assets, :http, :logger

  ASSET_REQUIRE_RE = /rad\.require[ \t]+['"]([a-zA-Z0-9_\-\.\/]+)['"]/

  def initialize path, cache
    raise "resources path should be absolute (#{path})!" unless path =~ /^\//
    if path.start_with?(http.root + assets.prefix)
      raise "resource can't explicitly include url root or asset prefix (#{path})!"
    end

    @source_path, @cache = path, cache
    @source_fs_path = assets.fs_path(path) || raise("no asset #{path}!")
  end

  def resolved_paths
    refresh_if_needed!
    if packable? and assets.pack?
      [http.root + assets.prefix + package_path]
    elsif buildable?
      (all_dependencies.collect(&:resolved_paths) + [http.root + assets.prefix + build_path]).flatten.uniq
    else
      (all_dependencies.collect(&:resolved_paths) + [http.root + assets.prefix + source_path]).flatten.uniq
    end
  end
  cache_method :resolved_paths

  protected
    def sources_fs_paths
      (all_dependencies.collect(&:source_fs_path) + [source_fs_path]).uniq
    end

    def builded_fs_paths
      paths = all_dependencies.collect{|d| d.buildable? ? d.build_fs_path : d.source_fs_path}
      paths << (buildable? ? build_fs_path : source_fs_path)
      paths.uniq
    end

    def refresh_if_needed! skip_packaging = false
      if !@dependencies_checked
        @dependencies_checked = true
        direct_dependencies.every.refresh_if_needed!(true)
      end

      if !@building_checked and buildable?
        @building_checked = true
        if !build_updated_at or
          build_updated_at < source_updated_at or
          all_dependencies.any?{|d| build_updated_at < d.source_updated_at}
        then
          logger.info "assets: building '#{source_path}' to '#{build_path}'"
          build!
        end
      end

      if !@packaging_checked and !skip_packaging and assets.pack? and packable?
        @packaging_checked = true
        if !package_updated_at or
          package_updated_at < source_updated_at or
          all_dependencies.any?{|d| package_updated_at < d.source_updated_at}
        then
          logger.info "assets: packaging '#{build_path}' to '#{package_path}'"
          pack!
        end
      end
    end

    def buildable?; respond_to? :build! end

    def packable?; respond_to? :pack! end

    def source_updated_at
      @source_updated_at ||= source_fs_path.to_file.updated_at
    end

    def build_updated_at
      @build_updated_at ||= build_fs_path.to_file.updated_at
    end

    def package_updated_at
      @package_updated_at ||= package_fs_path.to_file.updated_at
    end

    def build_path
      assets.build_prefix + source_path
    end

    def build_fs_path
      http.public_path + http.root + assets.prefix + build_path
    end

    def package_path
      assets.package_prefix + source_path
    end

    def package_fs_path
      http.public_path + http.root + assets.prefix + package_path
    end

    def direct_dependencies
      list = []
      source_fs_path.to_file.read.scan ASSET_REQUIRE_RE do |path|
        list << assets.get_resource(path.first, cache)
      end
      list.uniq
    end
    cache_method :direct_dependencies

    def all_dependencies
      list = []
      direct_dependencies.each do |dep|
        list.push *dep.all_dependencies
        list << dep
      end
      list.uniq
    end
    cache_method :all_dependencies
end