require "spec_helper"

describe "Module" do
  after do
    remove_constants %w(
      A X Y Z
      InheritableAccessorForModule
      InheritableAccessorForClass
      InheritableAccessor
      InheritableAccessorBase
      InheritableAccessorA
      InheritableAccessorB
    )
  end

  it "each_ancestor" do
    class X; end
    class Y < X; end
    class Z < Y; end

    list = []
    Z.each_ancestor{|a| list << a}
    list.should include Y
    list.should include X
    list.should_not include Z
    list.should_not include Object
    list.should_not include Kernel

    list = []
    Z.each_ancestor(true){|a| list << a}
    list.should include Y
    list.should include X
    list.should_not include Z
    list.should include Object
    list.should include Kernel
  end

  it "each_namespace" do
    class A
      class B
        class C

        end
      end
    end

    list = []
    A::B::C.each_namespace{|n| list << n}
    list.should == [A::B, A]
  end
end