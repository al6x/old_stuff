# Use it as a sample to crate Your own routers, usage:
# "/class_name/method_name?params" <=> [class, metod, params]
class Rad::Router::SimpleRouter
  def encode! klass, method, params
    path = "/#{klass.name.underscore}/#{method}"
    return path, params
  end

  def decode! path, params
    parts = path[1..-1].split '/'
    if parts.size >= 2
      method = parts.pop.to_sym

      class_path = parts.join('/')
      class_name = class_path.camelize
      klass = class_name.constantize

      return klass, method, path, params
    end
  end
end