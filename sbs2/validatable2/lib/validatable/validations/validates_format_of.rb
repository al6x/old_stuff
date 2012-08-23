module Validatable
  class ValidatesFormatOf < ValidationBase #:nodoc:
    attr_accessor :with

    def valid?(instance)
      value = instance.send(self.attribute)
      return true if allow_nil && value.nil?
      return true if allow_blank && (!value or (value.respond_to?(:empty?) and value.empty?))
      not (value.to_s =~ self.with).nil?
    end

    def message(instance)
      super || "is invalid"
    end
  end
end