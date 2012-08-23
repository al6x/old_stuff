module Rad::Assets::ViewHelper
  def packaged_assets *http_paths
    resolved_http_paths = []
    http_paths.each do |http_path|
      if rad.assets.asset? http_path
        resolved_http_paths.push *rad.assets.resolve_http_paths(http_path)
      else
        resolved_http_paths << http_path
      end
    end
    resolved_http_paths
  end

  def stylesheet_link_tag *a
    super(*packaged_assets(*a))
  end

  def javascript_include_tag *a
    super(*packaged_assets(*a))
  end
end