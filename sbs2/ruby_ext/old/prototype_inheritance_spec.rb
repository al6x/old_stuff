require "spec_helper"
require "ruby_ext/prototype_inheritance"

describe "Prototype Inheritance" do
  after do
    remove_constants :A, :B, :C
  end

  it "should define and override methods" do
    class A
      instance_methods do
        def instance_method
          'first version'
        end
      end
      class_methods do
        def class_method
          'first version'
        end
      end
    end

    A.new.instance_method.should == "first version"
    A.class_method.should == "first version"


    A.instance_methods do
      def instance_method
        'second version'
      end
    end

    A.class_methods do
      def class_method
        'second version'
      end
    end

    A.new.instance_method.should == "second version"
    A.class_method.should == "second version"
  end

  it "showcase" do
    class A
      instance_methods do
        def a; end

        def overrided_method
          'a version'
        end
      end

      class_methods do
        def class_a; end
      end

      def self.inherited target
        target.prototype.send :attr_accessor, :some_accessor
      end
    end

    class B
      instance_methods do
        def b; end

        def overrided_method
          'b version'
        end
      end

      class_methods do
        def class_b; end
      end
    end

    class C
      inherit A, B
    end

    c = C.new
    c.should respond_to(:a)
    c.should respond_to(:b)
    c.should respond_to(:some_accessor)

    C.should respond_to(:class_a)
    C.should respond_to(:class_b)
  end

  it "should inherit all ancestors class methods (and take order into account by overriding)" do
    class A
      instance_methods do
        def a; end

        def overrided
          'a'
        end
      end

      class_methods do
        def class_a; end
      end
    end

    class B
      inherit A

      instance_methods do
        def b; end

        def overrided
          'b'
        end
      end

      class_methods do
        def class_b; end
      end
    end

    class C
      inherit B
    end

    c = C.new
    c.should respond_to(:a)
    c.should respond_to(:b)
    c.overrided.should == 'b'

    C.should respond_to(:class_a)
    C.should respond_to(:class_b)

    C.instance_methods do
      def overrided
        'c'
      end
    end
    c = C.new
    c.overrided.should == 'c'
  end

  it "shouldn't redefine ancestors class methods (from error)" do
    class A
      class_methods do
        def class_method; end
      end
    end

    class B
      inherit A

      class_methods do
        def class_method2; end
      end
    end

    A.should_not respond_to(:class_method2)
  end

  it "methods defined on base class after inheritance must be propagated to all descendants" do
    class A; end

    class B
      inherit A
    end

    B.instance_methods.should_not include('method_added_after_inheritance')
    A.prototype.send(:define_method, :method_added_after_inheritance){}
    A.instance_methods.should include('method_added_after_inheritance')
    B.instance_methods.should include('method_added_after_inheritance')
  end

  it "classes included in base class after inheritance must be propagated to all descendants" do
    class A; end

    class B
      inherit A
    end

    class C
      instance_methods do
        def module_added_after_inheritance; end
      end
    end

    A.instance_methods.should_not include('module_added_after_inheritance')
    A.inherit C
    A.instance_methods.should include('module_added_after_inheritance')
    B.instance_methods.should include('module_added_after_inheritance')
  end
end