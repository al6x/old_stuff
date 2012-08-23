module Rad::Router::RouterHelper
  protected
    def parse_prefix options
      prefix = Array(options[:prefix])
      prefix.empty? ? nil : prefix
    end

    def encode_prefix_params! path, params, prefix
      parts = []
      prefix.each do |name|
        value = params.delete name
        raise "not provided :#{name} prefix!" unless value
        value = value.respond_to?(:to_param) ? value.to_param : value.to_s
        parts << value.to_s.url_escape
      end
      ["/#{parts.join('/')}#{path}", params]
    end

    def decode_prefix_params! path, parts, params, prefix
      prefix.each do |name|
        part = parts.shift || raise("not provided :#{name} prefix!")
        params[name] = part
        path = path[(part.size + 1)..-1]
      end
      [path, params]
    end

    def get_class name
      (@@classes_cache ||= {})[name] ||= name.constantize
    end
end