require 'rad/http/_rack_fixes'

class Rad::Http
  inject :logger

  # Configuration options.

  attr_accessor :host, :port, :root, :default_format, :maximum_data_size
  attr_required :host, :port, :root, :default_format, :maximum_data_size
  def assets?; !!@assets end

  attr_writer :public_path
  def public_path
    @public_path || "#{rad.runtime_path}/public"
  end
  def public_path?; !!public_path end

  attr_writer :browser_generated_types, :browser_generated_formats
  def browser_generated_types; @browser_generated_types ||= [] end
  def browser_generated_formats; @browser_generated_formats ||= [] end

  # Run Rack with Thin server.
  def run app
    require 'thin'

    # Disabling Thin greeting displayed to console, but enabling it later
    # to allowing it to report severe error messages.
    Thin::Logging.silent = true
    Thread.new do
      sleep 1
      Thin::Logging.silent = false
    end

    # Starting Thin.
    require 'rack'
    handler = Rack::Handler.get 'thin'
    handler.run app, Host: host, Port: port do |server|
      [:INT, :TERM].each do |sig|
        trap sig do
          server.respond_to?(:stop!) ? server.stop! : server.stop
          logger.info "\nHTTP server stopped"
        end
      end

      rad.environment
      logger.info "HTTP server started on http://#{host}:#{port}"
    end
  rescue Errno::EADDRINUSE => e
    logger.error "HTTP port #{port} taken!"
  end

  module Middleware
  end
end