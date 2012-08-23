Object.class_eval do
  def must
    ::Must::PositiveExpectation.new self
  end

  def must_not
    ::Must::NegativeExpectation.new self
  end
end

class AssertionError < RuntimeError; end

module Must
  class Expectation < BasicObject
    def initialize object
      @object = object
    end

    def to_s; inspect end

    # Special case, shortcut to write `a.must.be b` instead of `a.must.be_equal_to b`.
    def be *args
      if args.size == 1
        be_equal_to args.first
      elsif args.empty?
        self
      else
        raise ArgumentError, "invalid usage!"
      end
    end

    protected
      attr_reader :object

      def method_missing method, *args, &block
        original_method = method
        method, prefix, human_method = if method =~ /^be_/
          [:"#{method.to_s[3..-1]}?", :be, :"#{method.to_s[3..-1]}"]
        elsif method =~ /^have_/
          [:"#{method.to_s[5..-1]}?", :have, :"#{method.to_s[5..-1]}"]
        elsif method =~ /^[a-z_0-9]+$/
          [:"#{method}?", nil, method]
        else
          [method, nil, method]
        end
        special_method = :"_#{method}"

        # Defining method, to make it faster for future calls.
        instance_methods = ::Must::Expectation.instance_methods false
        if instance_methods.include? special_method
          define_special_method original_method, special_method, human_method, prefix
        else
          define_method original_method, method, human_method, prefix
        end

        __send__ original_method, *args, &block
      end

      # Special expectations.

      def _never_called?; false end
      def _nil?; object.equal? nil end
      def _defined?; !_nil? end
      def _equal_to? o; object == o end
      def _true?; !!object end
      def _false?; !object end
      def _a? *args; args.any?{|klass| object.is_a?(klass)} end
      # def _include o; object.include? o end
      # def _respond_to o; object.respond_to? o end
      alias_method :_an?, :_a?

      def _in? *args;
        list = (args.size == 1 and args.first.respond_to?(:include?)) ? args.first : args
        list.include? object
      end

      def p *args; ::Kernel.send :p, *args end

      def fail_expectation positive, human_method, prefix, *args, &block
        stack = ::Object.send(:caller).sfilter '/must.rb'

        msg =  "    ASSERTION FAILED (#{stack.first}):\n"
        msg << "    #{object.inspect[0..100]} must"
        msg << " not" unless positive
        msg << " #{prefix}" if prefix
        msg << " #{human_method}"
        msg << " #{args.collect(&:inspect).join(', ')}" unless args.empty?
        msg << " &..." if block

        ::Object.send :raise, ::AssertionError, msg, stack
      end
  end

  class PositiveExpectation < Expectation
    def inspect; "<#Must::PositiveExpectation #{object.inspect}>" end

    protected
      def define_special_method original_method, special_method, human_method, prefix
        ::Must::PositiveExpectation.define_method original_method do |*args, &block|
          unless self.__send__ special_method, *args, &block
            fail_expectation true, human_method, prefix, *args, &block
          end
          object
        end
      end

      def define_method original_method, method, human_method, prefix
        ::Must::PositiveExpectation.define_method original_method do |*args, &block|
          unless object.send method, *args, &block
            fail_expectation true, human_method, prefix, *args, &block
          end
          object
        end
      end
  end

  class NegativeExpectation < Expectation
    def inspect; "<#Must::NegativeExpectation #{object.inspect}>" end

    protected
      def define_special_method original_method, special_method, human_method, prefix
        ::Must::NegativeExpectation.define_method original_method do |*args, &block|
          if self.__send__ special_method, *args, &block
            fail_expectation false, human_method, prefix, *args, &block
          end
          object
        end
      end

      def define_method original_method, method, human_method, prefix
        ::Must::NegativeExpectation.define_method original_method do |*args, &block|
          if object.send method, *args, &block
            fail_expectation false, human_method, prefix, *args, &block
          end
          object
        end
      end
  end
end