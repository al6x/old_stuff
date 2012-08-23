class RubyExt::CallbacksProxy < BasicObject
  attr_reader :object

  def initialize object, callback_name
    @object, @callback_name = object, callback_name
  end

  def callback_proxy?
    true
  end

  alias_method :send, :__send__
  alias_method :public_send, :__send__

  protected
    def method_missing m, *args, &block
      object.run_callbacks @callback_name, m do
        object.public_send m, *args, &block
      end
    end
end