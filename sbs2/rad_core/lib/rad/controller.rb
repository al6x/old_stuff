module Rad::Controller
  inherit RubyExt::OpenConstructor, Rad::Filters

  inject :logger

  def t *args; rad.locale.t *args end

  module ClassMethods
    inject :logger

    # Wrapping every controller object with proxy that enforces callbacks.
    def new *args, &block
      controller = super
      RubyExt::CallbacksProxy.new controller, :action
    end

    def t *args; rad.locale.t *args end
  end
end