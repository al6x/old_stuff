class Rad::Http::Router < Rad::Router
  def build_url *args
    first = args.first
    if first.is_a?(Class)
      args.size.must.be_in 2..3
      klass, method, params = args

      path, params = encode klass, method, (params || {})
      build_url_path path, params
    else
      if first =~ /^\//
        args.size.must.be_in 1..2
        path, params = args
        params ||= {}

        # Because we don't use `encode` method we should add
        # :root and :format manually.
        path = root + path if root
        path, params = formatter.encode! path, params if formatter

        build_url_path path, params
      elsif first =~ /^http:\/\//
        args.size.must.be_in 1..2
        raise "can't use params with full url (#{first})" if args.size == 2 and !args.last.blank?
        first
      else
        must.be_never_called
      end
    end
  end

  protected
    def build_url_path path, params = {}
      # Cloning and simultaneously rejecting nil parameters.
      path, params = path.clone, params.reject{|k, v| v.blank?}

      # Root.
      # root = params.delete :root
      # url = (root && root != '/') ? root + path : path.clone

      # Host, port, format.
      host, port = params.delete(:host), params.delete(:port)

      # Encoding format.
      # path, params = formatter.encode! path, params if formatter

      # Json conversion.
      params = {json: params.to_json} if params.delete :as_json

      # Building url.
      delimiter = path.include?('?') ? '&' : '?'
      unless params.empty?
        path << delimiter
        path << params.collect{|k, v| "#{k.to_s.uri_escape}=#{v.to_s.uri_escape}"}.join('&')
      end

      if host.blank?
        path
      else
        %{http://#{host}#{":#{port}" unless port.blank?}#{path}}
      end
    end
end