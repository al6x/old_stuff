require 'rack'
require 'rack/builder'

class Rad::Http::RackAdapter
  SERVERS = %w{thin mongrel webrick}

  inject :logger

  def configure_rack! builder
    raise "Rack stack not defined! Use profiles (see rad/profiles/web.rb), or use your own configuration!" if stack.empty?
    stack.each{|conf| conf.call builder}
  end

  def stack
    @rack_stack ||= []
  end

  def run app, host, port
    handler = detect_rack_handler
    handler_name = handler.name.gsub /.*::/, ''
    logger.info "RAD http server started on #{host}:#{port}" unless rad.test?
    # unless handler_name =~/cgi/i
    handler.run app, Host: host, Port: port do |server|
      [:INT, :TERM].each {|sig| trap(sig){quit!(server, handler_name)}}
    end
  rescue Errno::EADDRINUSE => e
    logger.error "RAD port #{port} taken!"
  end

  def quit!(server, handler_name)
    ## Use thins' hard #stop! if available, otherwise just #stop
    server.respond_to?(:stop!) ? server.stop! : server.stop
    puts "\nRad stopped" unless handler_name =~/cgi/i
  end

  protected
    def detect_rack_handler
      return Rack::Handler.get('thin')
      SERVERS.each do |server_name|
        begin
          return Rack::Handler.get(server_name.downcase)
        rescue LoadError
        rescue NameError
        end
      end
      fail "  Server handler (#{SERVERS.join(', ')}) not found."
    end

  # end
end