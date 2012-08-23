module Validatable
  # call-seq: valid?
  #
  # Returns true if no errors were added otherwise false. Only executes validations that have no :groups option specified
  def valid?
    validate
    errors.empty?
  end

  # call-seq: errors
  #
  # Returns the Errors object that holds all information about attribute error messages.
  def errors
    @_errors ||= Validatable::Errors.new
  end

  def validate
    return true unless errors.empty?

    self.class.all_validations.each do |validation|
      validation.validate self
    end
    errors.empty?
  end

  module ClassMethods #:nodoc:
    include ::Validatable::Macros

    def all_validations
      if self.respond_to?(:superclass) && self.superclass.respond_to?(:all_validations)
        return validations + self.superclass.all_validations
      end
      validations
    end

    def validations
      @validations ||= []
    end

    protected
      def add_validations(args, klass)
        options = args.last.is_a?(Hash) ? args.pop : {}
        args.each do |attribute|
          new_validation = klass.new self, attribute, options
          self.validations << new_validation
        end
      end
  end
end