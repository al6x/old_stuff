require "spec_helper"

describe 'DeclarativeCache' do
  after{remove_constants :Tmp, :TmpModule}

  # class CachedClass
  #   attr_accessor :value
  #   def value_get; @value end
  #   cache_method :value_get
  #
  #   attr_accessor :value2
  #   def value2_get; @value2 end
  #
  #   attr_accessor :params
  #   def params_get param; @params[param] end
  #
  #   attr_accessor :multiplier
  #   def *(arg)
  #     @multiplier * arg
  #   end
  #   cache_method_with_params '*'
  # end
  #
  # RubyExt::DeclarativeCache.cache_method CachedClass, :value2_get
  # RubyExt::DeclarativeCache.cache_method_with_params CachedClass, :params_get

  it "basics" do
    class Tmp
      attr_accessor :value
      def value_get; @value end
      cache_method :value_get
    end

    o = Tmp.new
    o.value = 0
    o.value_get.should == 0

    o.value = 1
    o.value_get.should == 0
  end

  it "should define {method}_with_cache and {method}_without_cache methods" do
    class Tmp
      attr_accessor :value
      def value_get; @value end
      cache_method :value_get

      attr_accessor :params
      def params_get param; @params[param] end
      cache_method_with_params :params_get
    end

    o = Tmp.new

    # Without params.
    o.value = 0
    o.value_get.should == 0
    o.value = 1
    o.value_get.should == 0
    o.value_get_with_cache.should == 0
    o.value_get_without_cache.should == 1

    # With params.
    o.params = {a: :b}
    o.params_get(:a).should == :b
    o.params = {a: :c}
    o.params_get(:a).should == :b
    o.params_get_with_cache(:a).should == :b
    o.params_get_without_cache(:a).should == :c
  end

  it "clear_cache" do
    class Tmp
      attr_accessor :value
      def value_get; @value end
      cache_method :value_get
    end

    o = Tmp.new
    o.value = 0
    o.value_get.should == 0

    o.value = 1
    o.value_get.should == 0

    Module.clear_cache o
    o.value_get.should == 1
  end

  it "should check for method signature" do
    class Tmp
      def value_get; @value end
      cache_method :value_get
    end

    o = Tmp.new
    lambda{o.value_get(1)}.should raise_error(/cache_method_with_params/)
  end

  it "cache_method_with_params" do
    class Tmp
      attr_accessor :params
      def params_get param; @params[param] end
      cache_method_with_params :params_get
    end

    o = Tmp.new
    o.params = {a: :b}
    o.params_get(:a).should == :b
    o.params = {a: :c}
    o.params_get(:a).should == :b
  end

  it "should works with operators" do
    class Tmp
      attr_accessor :multiplier
      def *(arg)
        @multiplier * arg
      end
      cache_method_with_params '*'
    end

    o = Tmp.new
    o.multiplier = 2
    (o * 2).should == 4
    o.multiplier = 3
    (o * 2).should == 4
  end

  it "should works with singleton classes" do
    class Tmp
      class << self
        attr_accessor :value
        def value_get; @value end
        cache_method :value_get
      end
    end

    Tmp.value = 0
    Tmp.value_get.should == 0
    Tmp.value = 1
    Tmp.value_get.should == 0
  end

  it "should works with included modules (from error)" do
    module TmpModule
      attr_accessor :value
      def value_get; @value end
      cache_method :value_get
    end

    class Tmp
      include TmpModule
    end

    o = Tmp.new
    o.value = 0
    o.value_get.should == 0

    o.value = 1
    o.value_get.should == 0
  end
end