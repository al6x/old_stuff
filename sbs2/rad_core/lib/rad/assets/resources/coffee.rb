class Rad::Assets::Resources::Coffee < Rad::Assets::Resources::Js
  def build!
    out = %x(coffee --compile --output #{build_fs_path.to_file.parent} #{source_fs_path})
    if out =~ /Error/i
      rad.logger.error "assets: can't build '#{fs_path}' file!\n#{out}"
      raise "can't build '#{fs_path}' file!"
    end
  end

  def build_path
    as_js super
  end

  def build_fs_path
    as_js super
  end

  def package_path
    as_js super
  end

  def package_fs_path
    as_js super
  end

  protected
    def as_js path
      path.sub /\.coffee$/, '.js'
    end
end