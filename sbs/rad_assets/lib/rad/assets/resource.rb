class Rad::Assets::Resource
  attr_reader :http_path
  inject assets: :assets

  ASSET_REQUIRE_RE = /rad\.assets\.require[ \t]+['"]([a-zA-Z0-9_\-\.\/]+)['"]/

  def initialize http_path
    raise "resources path should be absolute (#{http_path})!" unless http_path =~ /^\//
    @http_path = http_path
  end

  def resolved_http_paths
    fs_path = assets.fs_path(http_path) || raise("no asset #{http_path}!")
    paths = []
    fs_path.to_file.read.scan ASSET_REQUIRE_RE do |dependency_http_path|
      res = Rad::Assets::Resource.new(dependency_http_path.first)
      paths.push *res.resolved_http_paths
    end
    paths << "#{assets.static_path_prefix}#{http_path}"
    paths.uniq
  end
end