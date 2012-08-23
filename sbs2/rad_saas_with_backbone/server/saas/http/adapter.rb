class Saas::Http::Adapter
  inject :request, :params, :response, :http_router, :template, :environment, :locale, :logger

  inherit Saas::Http::UserHelper, Saas::Http::AccountHelper

  def call env
    if request.path.start_with? rad.http.root
      process
    else
      proxy
    end
  end

  protected
    def process
      # Routing.
      klass, method, path2, params2 = http_router.decode request.path, request.params
      route_found = !!klass

      # Updating request path, params and format to its normalized versions.
      request.set path: path2, params: params2
      self.params = params2

      # Format.
      if format = params.delete(:format)
        request.format, response.format = format, format
      end

      # Localization.
      locale.current = params[:l]

      # Preparing account and space.
      rad.account = get_account
      if space_name = params[:space_name]
        space = rad.account.get_space space_name
        rad.space = space if space
      end

      # Preparing user.
      rad.user = get_user
      logger.info %(HTTP: logged as #{rad.user.name} in #{rad.account.name}#{"/#{rad.space.name}" if rad.space?})

      # Calling Controller.
      if route_found
        controller = klass.new

        # args = request.args
        # Symbolizing every hash in arbitrary objects, recursivelly.
        # args = Hash.symbolize args

        # args_str = args.collect(&:inspect).join(', ')
        msg = "CONTROLLER calling #{klass}.#{method}"
        msg += ' with ' + params.inspect unless params.empty?
        msg = msg[0..200] + ' ...' if msg.size > 200
        logger.info msg

        # Calling Controller.
        result = controller.public_send method
        # result = controller.run_callbacks :action, method do
        #   controller.public_send method
        # end

        msg = "CONTROLLER response #{result.inspect}"
        msg = msg[0..200] + ' ...' if msg.size > 200
        logger.info msg
      else
        result = nil
      end

      # Assembling response.
      if request.format == 'json'
        response.body = result ? JSON.pretty_generate(result) : result.to_json
      elsif request.format == 'html'
        render_client result
      else
        response.set! status: :failed, body: "unknown format!"
      end

      response
    end

    def proxy
      [200, {"Content-Type" => "text/plain"}, ["Proxying"]]
    end

    def render_client result
      # Caching client html in production, except of the small dynamic piece.
      if !rad.production? or !@begin_cache
        @begin_cache = template.render_html '/saas/app_static_begin.html'
        @end_cache   = template.render_html '/saas/app_static_end.html'
      end
      dynamic = template.render_html('/saas/app_dynamic.js', locals: {result: result}).indent(4)

      response.body << @begin_cache
      response.body << dynamic
      response.body << @end_cache
    end
end