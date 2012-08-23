class Rad::Http::Middleware::NoWww
  inject :request, :response

  def initialize app
    @app = app
  end

  def call env
    if request.format == 'html' and request.uri.host =~ /^www\./
      uri = request.uri.clone
      uri.host = uri.host.sub /^www\./, ''

      response.set! \
        status:   301,
        location: uri.to_s,
        body:     %(<html><body>You are being <a href="#{url.html_escape}">redirected</a>.</body></html>)
    else
      @app.call env
    end
  end
end