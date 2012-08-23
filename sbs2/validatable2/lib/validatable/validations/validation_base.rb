module Validatable
  class ValidationBase #:nodoc:
    attr_accessor :message, :if, :after_validate, :allow_nil, :allow_blank
    attr_accessor :attribute, :klass

    def initialize(klass, attribute, options={})
      self.klass = klass
      options.each{|k, v| self.send :"#{k}=", v}
      self.attribute = attribute
    end

    def validate instance
      if should_validate?(instance) and !valid?(instance)
        instance.errors.add attribute, message(self)
      end
    end

    protected
      def message instance
        @message.respond_to?(:call) ? instance.instance_eval(&@message) : @message
      end

      def should_validate? instance
        result = true # validate_this_time?(instance)
        case self.if
          when Proc
            result &&= instance.instance_eval(&self.if)
          when Symbol, String
            result &&= instance.instance_eval(self.if.to_s)
        end
        result
      end
  end
end