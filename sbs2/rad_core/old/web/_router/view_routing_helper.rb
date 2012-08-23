module Rad::ViewRoutingHelper
  inherit Rad::AbstractRoutingHelper

  def link_to *args, &block
    # content
    content = if block
      capture(&block)
    else
      args.shift
    end

    # url, html_options
    if args.first.is_a? String
      args.size.must.be_in 1..2
      url, html_options = args
      html_options ||= {}
    else
      if url = special_url(args.first)
        args.size.must.be <= 2
        html_options = args[1] || {}
      else
        html_options = if args[-1].is_a?(Hash) and args[-2].is_a?(Hash)
          args.pop
        else
          {}
        end

        args << {} unless args[-1].is_a?(Hash)
        url = build_url(*args)
      end
    end

    # add javascript
    html_options[:href] = url
    add_js_link_options! url, html_options
    tag :a, content, html_options
  end

  protected
    def add_js_link_options! url, html_options
      remote = html_options.delete(:remote) || rad.html.remote_link_formats.include?(url.marks.format)
      method = html_options.delete(:method)

      if remote or method
        action = html_options.delete(:href).must.be_defined
        html_options[:href] = '#'

        html_options['data-action'] = action
        html_options['data-remote'] = 'true' if remote
        html_options['data-method'] = method || 'post'
      end

      if confirm = html_options.delete(:confirm)
        html_options['data-confirm'] = confirm
      end
    end
end