module Validatable
  class ValidatesLengthOf < ValidationBase #:nodoc:
    attr_accessor :minimum, :maximum, :is, :in

    def message(instance)
      super || "is invalid"
    end

    def valid?(instance)
      valid = true
      value = instance.send(self.attribute)

      if value.nil?
        return true if allow_nil
        value = ''
      end

      if !value or (value.respond_to?(:empty?) and value.empty?)
        return true if allow_blank
        value = ''
      end

      valid &&= value.length <= maximum unless maximum.nil?
      valid &&= value.length >= minimum unless minimum.nil?
      valid &&= value.length == is unless is.nil?
      valid &&= self.in.include?(value.length) unless self.in.nil?
      valid
    end
  end
end