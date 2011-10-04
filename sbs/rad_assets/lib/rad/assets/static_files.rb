class Rad::Assets::StaticFiles < Rack::File
  def initialize(app, filter = nil)
    @app, @filter = app, filter
  end

  def call(env)
    path = env["PATH_INFO"]

    if path != '/' and (!@filter or (@filter and @filter =~ path)) and (resolved_path = find_file(path))
      @path = resolved_path
      serving(env)
    else
      @app.call(env)
    end
  end

  protected
    inject assets: :assets

    def find_file http_path
      http_path = http_path.url_unescape
      if rad.http.public_path?
        fs_path = "#{rad.http.public_path}#{http_path}"
        return fs_path if fs_path.to_file.exist?
      end

      if rad.development?
        http_path = http_path.sub rad.assets.static_path_prefix, ''
        fs_path = assets.fs_path http_path
        fs_path.sub rad.http.public_path, '' if fs_path
      end
    end
end