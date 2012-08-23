module Validatable
  class ValidatesInclusionOf < ValidationBase
    attr_accessor :in

    def valid?(instance)
      value = instance.send(attribute)
      return true if allow_nil && value.nil?
      return true if allow_blank && (!value or (value.respond_to?(:empty?) and value.empty?))

      self. in.include?(value)
    end

    def message(instance)
      super || "is not in the list"
    end
  end
end