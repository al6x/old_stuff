class PackagedResource < Rad::Assets::Resource
  PACKAGED_POSTFIX = 'packaged'

  def get
    path = "#{assets.prefix}#{self.path}"

    fs_path = self.fs_path path
    paths = []
    fs_path.to_file.read.scan ASSET_REQUIRE_RE do |dependency_path|
      res = Rad::Assets::PackagedResource.new(dependency_path.first)
      paths.push *res.get
    end
    paths << path

    fs_paths = paths.collect{|path| self.fs_path path}
    packaged_file = self.fs_path(packaged_path(path)).to_file

    rebuild = (
      !packaged_file.exist? or
      fs_paths.any?{|path| path.to_file.updated_at > packaged_file.updated_at}
    )
    rebuild! packaged_file, fs_paths if rebuild

    [packaged_path(path)]
  end

  protected
    def fs_path path
      "#{rad.http.public_path}#{path}"
    end

    def packaged_path path
      extension = File.extname(path)
      base = path[0..(path.size - extension.size - 1)]
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