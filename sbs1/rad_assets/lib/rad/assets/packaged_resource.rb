class Rad::Assets::PackagedResource < Rad::Assets::Resource
  PACKAGED_POSTFIX = 'packaged'

  def resolved_http_paths
    http_path = "#{assets.static_path_prefix}#{self.http_path}"

    fs_path = self.fs_path http_path
    http_paths = []
    fs_path.to_file.read.scan ASSET_REQUIRE_RE do |dependency_http_path|
      res = Rad::Assets::PackagedResource.new(dependency_http_path.first)
      http_paths.push *res.resolved_http_paths
    end
    http_paths << http_path

    fs_paths = http_paths.collect{|path| self.fs_path path}
    packaged_file = self.fs_path(packaged_http_path(http_path)).to_file

    rebuild = (
      !packaged_file.exist? or
      fs_paths.any?{|path| path.to_file.updated_at > packaged_file.updated_at}
    )
    rebuild! packaged_file, fs_paths if rebuild

    [packaged_http_path(http_path)]
  end

  protected
    def fs_path http_path
      "#{rad.http.public_path}#{http_path}"
    end

    def packaged_http_path http_path
      extension = File.extname(http_path)
      base = http_path[0..(http_path.size - extension.size - 1)]
      "#{base}.packaged#{extension}"
    end

    def rebuild! packaged_file, fs_paths
      # merging
      packaged_file.write do |writer|
        fs_paths.each do |path|
          path.to_file.read do |buff|
            writer.write buff
          end
        end
      end

      # packing
      Rad::Assets::Compressor.pack! packaged_file.path
    end
end