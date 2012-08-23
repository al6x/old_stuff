require 'rack/file'

class Rad::Assets::Middleware::Server < Rack::File
  def initialize app = nil, filter = nil
    @app, @filter = app, filter
  end

  def call env
    path = env["PATH_INFO"]
    if path != '/' and (!filter or filter =~ path) and (resolved_path = find_file(path))
      @path = resolved_path
      serving env
    else
      @app.call env if @app
    end
  end

  protected
    attr_reader :filter
    inject :assets

    def find_file path
      path = path.url_unescape.sub rad.http.root + rad.assets.prefix, ''
      assets.fs_path path
    end
end