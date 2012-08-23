# FactoryGirl replacement (because original FactoryGirl is bloated, and
# even more - it depends on activesupport, and this makes it too
# unconvinient to use in non-Rails environments).

class Factory
  class Builder
    attr_reader :name, :klass, :parent, :initializer

    def initialize name, options = {}, &initializer
      @initializer = initializer
      @klass, @parent = options[:class], options[:parent]
      unless klass or parent or initializer
        raise "there are nor class nor initializer nor parent provided for :#{name}!"
      end
    end

    def build attributes = {}, &block
      if parent
        o = factory.build parent
        initializer.call o if initializer
      elsif klass
        real_class = self.klass.is_a?(String) ? self.klass.constantize : self.klass
        o = real_class.new
        initializer.call o if initializer
      elsif initializer
        o = initializer.call
      end

      attributes.each{|name, value| o.send :"#{name}=", value}
      block.call o if block

      o
    end
  end

  attr_reader :registry, :counters

  def initialize
    @registry, @counters = {}, Hash.new(0)
  end

  def define name, options = {}, &initializer
    raise "definition of :#{name} already exist!" if registry.include? name
    registry[name] = Builder.new(name, options, &initializer)
  end

  def build name, attributes = {}, &block
    old = creation_method
    begin
      self.creation_method ||= :build

      builder = registry[name] || raise("no definition for :#{name}!")
      builder.build attributes, &block
    ensure
      self.creation_method = old
    end
  end

  def create name, attributes = {}, &block
    old = creation_method
    begin
      self.creation_method ||= :create

      o = build name, attributes, &block
      o.respond_to?(:save!) ? o.save! : o.save
      o
    ensure
      self.creation_method = old
    end
  end

  def auto *args, &block
    method = creation_method || raise("creation method not defined!")
    send method, *args, &block
  end

  def next name = :general
    v = counters[name]
    counters[name] += 1
    v
  end

  protected
    attr_accessor :creation_method
end

def factory *args
  autoload :Factory, 'rspec_ext/factory'
  if args.empty?
    $factory ||= Factory.new
  else
    factory.auto *args
  end
end