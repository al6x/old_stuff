# RSpec doesn't support methods for BasicObject, adding it by hand.
RubyExt::CallbacksProxy.class_eval do
  delegate :should, :should_not, :should_receive, :should_not_receive, :stub!, to: :object

  def call method, params = {}
    rad = ::Kernel.send :rad
    rad.params = params
    method_missing method
  end
end