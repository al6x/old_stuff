module RubyExt::Callbacks
  class AbstractCallback
    attr_reader :executor
    def executor= executor
      @executor = executor.must.be_a Symbol, Proc
    end

    attr_reader :conditions
    def conditions= conditions
      @conditions = {}
      conditions.each do |k, v|
        @conditions[k] = if v.is_a? Symbol
          v
        elsif v.is_a? Array
          raise "method names must be symbols (#{v})!" unless v.all?{|e| e.is_a? Symbol}
          v
        else
          v
        end
      end
      @conditions
    end

    def run? target, method, data
      if cond = conditions[:if]
        evaluate_if(cond, target, data)
      elsif cond = conditions[:unless]
        !evaluate_if(cond, target, data)
      elsif cond = conditions[:only]
        evaluate_only(cond, method, data)
      elsif cond = conditions[:except]
        !evaluate_only(cond, method, data)
      else
        true
      end
    end

    alias_method :deep_clone, :clone

    protected
      def evaluate_if cond, target, data
        if cond.is_a? Symbol
          target.send cond
        elsif cond.is_a? Proc
          cond.call target, data
        else
          must.be_never_called
        end
      end

      def evaluate_only cond, method, data
        method.must.be_a Symbol if method
        if cond.is_a? Symbol
          cond == method
        elsif cond.is_a? Array
          cond.include? method
        else
          must.be_never_called
        end
      end
  end

  class BeforeCallback < AbstractCallback
    attr_accessor :terminator

    def build_block target, method, data, &block
      -> do
        if run? target, method, data
          block.call if run target, data
        else
          block.call
        end
      end
    end

    def run target, data
      callback_result = if executor.is_a? Symbol
        target.send executor
      elsif executor.is_a? Proc
        executor.call target
      else
        must.be_never_called
      end

      !terminate?(target, callback_result)
    end

    protected
      def terminate? target, result
        unless terminator.nil?
          if terminator.is_a? Proc
            terminator.call target, result
          else
            result == terminator
          end
        else
          false
        end
      end
  end

  class AfterCallback < AbstractCallback
    def build_block target, method, data, &block
      -> do
        if run? target, method, data
          result = block.call
          run target, data
          result
        else
          block.call
        end
      end
    end

    def run target, data
      if executor.is_a? Symbol
        target.send executor
      elsif executor.is_a? Proc
        executor.call target
      else
        must.be_never_called
      end
    end
  end

  class AroundCallback < AbstractCallback
    def build_block target, method, data, &block
      -> do
        if run? target, method, data
          run target, data, &block
        else
          block.call
        end
      end
    end

    def run target, data, &block
      if executor.is_a? Symbol
        target.send executor, &block
      elsif executor.is_a? Proc
        executor.call target, block
      else
        must.be_never_called
      end
    end
  end

  def run_before_callbacks name, method, data = {}
    name.must.be_a Symbol
    self.class.callbacks[name].try :each do |callback|
      if callback.is_a?(BeforeCallback) and callback.run?(self, method, data)
        return false unless callback.run(self, data)
      end
    end
    true
  end

  def run_after_callbacks name, method, data = {}
    name.must.be_a Symbol
    self.class.callbacks[name].try :each do |callback|
      if callback.is_a?(AfterCallback) and callback.run?(self, method, data)
        callback.run(self, data)
      end
    end
  end

  def run_callbacks name, method, data = {}, &block
    name.must.be_a Symbol
    run_callbacks_once name, method, block do
      if callbacks = self.class.callbacks[name]
        chain = block || -> {}
        chain = callbacks.reverse.reduce chain do |chain, callback|
          callback.build_block self, method, data, &chain
        end
        chain.call
      else
        block.call if block
      end
    end
  end

  # We need to prevent callback from rinning multiple times if nested.
  def run_callbacks_once name, method, block_without_callbacks, &block
    set = Thread.current[:callbacks] ||= {}
    id = "#{object_id}/#{name}/#{method}"
    if set.include? id
      block_without_callbacks.call if block_without_callbacks
    else
      begin
        set[id] = true
        block.call
      ensure
        set.delete id
      end
    end
  end
  protected :run_callbacks_once

  module ClassMethods
    inheritable_accessor :callbacks, {}

    def set_callback name, type, *executor_or_options, &block
      name.must.be_a Symbol
      type = type.to_sym

      # Parsing arguments.
      opt = executor_or_options.extract_options!
      "You can't provide both method name and block for filter!" if block and !executor_or_options.empty?
      executor = block || executor_or_options.first

      type.must.be_in [:before, :around, :after]
      executor.must.be_defined

      # Creating callback.
      callback = AbstractCallback.new
      callback = case type
      when :before then BeforeCallback.new
      when :around then AroundCallback.new
      when :after then AfterCallback.new
      end

      callback.executor = executor
      callback.terminator = opt.delete :terminator if type == :before
      callback.conditions = opt

      (self.callbacks[name] ||= []) << callback
    end

    def wrap_method_with_callbacks method, callback
      method_without_callback = :"#{method}_without_#{callback}_of_#{self.alias}"
      if method_defined? method_without_callback
        raise "can't wrap method #{method} with #{callback} of #{self.alias} twice!"
      end

      alias_method method_without_callback, method
      define_method method do |*args, &block|
        # We can't use run_callbacks, because in case of the `super`
        # call it will be runned twice.
        run_callbacks callback, method do
          send method_without_callback, *args, &block
        end
      end
    end

    def wrap_with_callback callback
      instance_methods(false).each do |method|
        wrap_method_with_callbacks method, callback
      end
    end
  end
end