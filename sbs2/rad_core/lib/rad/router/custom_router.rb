# Custom router.
class Rad::Router::CustomRouter
  attr_accessor :custom_decode, :custom_encode

  def encode! klass, method, params
    custom_encode.call klass, method, params if custom_encode
  end

  def decode! path, params
    custom_decode.call path, params if custom_decode
  end
end

Rad::Router::Configurator.class_eval do
  def get_custom_router
    router = @router.routers.find{|router| router.is_a? ::Rad::Router::CustomRouter}
    raise "There's no #{::Rad::Router::CustomRouter} (use config to add it)!" unless router
    router
  end

  def custom_decode &block
    get_custom_router.custom_decode = block
  end

  def custom_encode &block
    get_custom_router.custom_encode = block
  end
end