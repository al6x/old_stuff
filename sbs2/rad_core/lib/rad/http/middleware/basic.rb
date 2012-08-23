class Rad::Http::Middleware::Basic
  inject :request, :params, :response, :logger

  def initialize app
    @app = app
  end

  def call env
    begin
      rad.activate :cycle do
        # Preparing Request and Response.
        rack_request = Rad::Http::RackRequest.new env
        self.request = Rad::Http::Request.new rack_request
        self.params = request.params
        self.response = Rad::Http::Response.new request

        # Logging.
        msg = "\nHTTP processing '#{request.path}' with #{request.params.inspect.gsub("\\", '')}"
        msg << " as :#{request.format} using :#{request.method.downcase}"
        msg << " on #{rack_request.ip} at #{Time.now.to_s}"
        logger.info msg

        @app.call env
      end
    rescue => e
      logger.error e
      render_error e
    end
  end

  protected
    def render_error error
      if rad.development?
        msg = <<-HTML
<html>
<body>
	<p>
		<b><font color='red'>ERROR:</font></b>
		#{error.message.html_escape}
	</p>
	<pre>
  #{error.backtrace && error.backtrace.join("\n  ").html_escape}
	</pre>
</body>
</html>
HTML
        [500, {"Content-Type" => "text/html"},  [msg]]
      else
        [500, {"Content-Type" => "text/plain"}, ["Internal error!"]]
      end
    end
end