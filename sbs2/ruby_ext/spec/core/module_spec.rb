require "spec_helper"

describe "Module" do
  after{remove_constants :A, :B, :C, :ABase}

  it "namespace" do
    class A
      class B
        class C; end
      end
    end

    A.namespace.should == nil
    A::B::C.namespace.should == A::B
  end

  it "alias" do
    class A
      class B
        class C; end
      end
    end

    A::B::C.alias.should == 'C'
    A::B::C.name.should == "A::B::C"
  end

  it "is?" do
    Fixnum.is?(Numeric).should be_true
  end

  it "escape_method" do
    Module.escape_method(:">_<_=_?").should == :gt_lt_assign_qst
  end

  describe "inheritable_accessor" do
    it "module" do
      module A
        module ClassMethods
          inheritable_accessor :callbacks, [:a]
          inheritable_accessor :layout, 'a'
        end
      end

      class B
        inherit A
        callbacks << :b
        self.layout = 'b'
      end

      B.callbacks.should == [:a, :b]
      B.layout.should == 'b'
    end

    it "class" do
      class A
        class << self
          inheritable_accessor :callbacks, [:a]
          inheritable_accessor :layout, 'a'
        end
        callbacks << :a2
      end

      class B < A
        callbacks << :b
        self.layout = 'b'
      end

      A.callbacks.should == [:a, :a2]
      B.callbacks.should == [:a, :a2, :b]

      A.layout.should == 'a'
      B.layout.should == 'b'
    end

    it "should correcly clone attributes (from error)" do
      module ABase
        module ClassMethods
          inheritable_accessor :callbacks, []
        end
      end

      class A
        inherit ABase
        callbacks << :a
      end

      class B
        inherit ABase
        callbacks << :b
      end

      A.callbacks.should == [:a]
      B.callbacks.should == [:b]
    end
  end

  it "delegate" do
    class A
      attr_accessor :target
      delegate :a, to: :target
    end

    a = A.new
    a.target = stub
    a.target.should_receive(:a).with(:b)
    a.a :b
  end
end