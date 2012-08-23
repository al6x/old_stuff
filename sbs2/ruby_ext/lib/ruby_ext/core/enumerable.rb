Enumerable.class_eval do
  class ::Enumerable::EveryProxy < BasicObject
    def initialize enumerable
      @enumerable = enumerable
    end

    protected
      def method_missing m, *a, &b
        @enumerable.each{|o| o.send m, *a, &b}
        self
      end
  end

  def every
    ::Enumerable::EveryProxy.new self
  end
end