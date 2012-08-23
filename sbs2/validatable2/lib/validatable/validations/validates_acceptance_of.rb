module Validatable
  class ValidatesAcceptanceOf < ValidationBase #:nodoc:
    def valid?(instance)
      value = instance.send(self.attribute)
      return true if allow_nil && value.nil?
      return true if allow_blank && (!value or (value.respond_to?(:empty?) and value.empty?))
      %w(1 true t).include?(value)
    end

    def message(instance)
      super || "must be accepted"
    end
  end
end