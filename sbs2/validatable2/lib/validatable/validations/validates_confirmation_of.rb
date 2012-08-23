module Validatable
  class ValidatesConfirmationOf < ValidationBase #:nodoc:
    attr_accessor :case_sensitive

    def initialize(klass, attribute, options={})
      klass.class_eval do
        attr_accessor "_#{attribute}_confirmation"
        alias_method "#{attribute}_confirmation", "_#{attribute}_confirmation"
        alias_method "#{attribute}_confirmation=", "_#{attribute}_confirmation="
      end
      super
      self.case_sensitive = true if self.case_sensitive == nil
    end

    def valid?(instance)
      confirmation_value = instance.send("#{self.attribute}_confirmation")
      return true if allow_nil && confirmation_value.nil?
      return true if allow_blank && (!confirmation_value or (confirmation_value.respond_to?(:empty?) and confirmation_value.empty?))
      return instance.send(self.attribute) == instance.send("#{self.attribute}_confirmation".to_sym) if case_sensitive
      instance.send(self.attribute).to_s.casecmp(instance.send("#{self.attribute}_confirmation".to_sym).to_s) == 0
    end

    def message(instance)
      super || "doesn't match confirmation"
    end
  end
end