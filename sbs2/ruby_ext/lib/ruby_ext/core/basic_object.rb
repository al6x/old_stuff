BasicObject.class_eval do
  protected :==, :equal?, :!, :!=, :instance_eval, :instance_exec

  protected
    def raise *args
      ::Object.send :raise, *args
    end
end