module Rad::ControllerRoutingHelper
  inherit Rad::AbstractRoutingHelper

  module ClassMethods

    #
    # persist_params controller filters
    #
    def persist_params *args
      if args.empty?
        before :persist_params
      elsif args.first.is_a? Hash
        before :persist_params, args.first
      else
        before :persist_params, only: args.first
      end
    end
  end

  #
  # redirect_to
  #
  def redirect_to *args
    params, response = workspace.params, workspace.response
    params.format.must.be_in 'html', 'js'

    if url = special_url(args.first)
      args.size.must.be <= 1
    else
      url = build_url(*args)
    end
    content_type = Rad::Mime[params.format]

    content = if params.format == 'js'
      response.set!(
        status: :ok,
        content_type: content_type
      )

      "window.location = '#{url}';"
    else
      response.set!(
        status: :redirect,
        content_type: content_type
      )
      response.headers['Location'] = url

      %(<html><body>You are being <a href="#{url.html_escape if url}">redirected</a>.</body></html>)
    end

    # Flash need to know if we using redirect
    keep_flash!

    throw :halt, content
  end
end