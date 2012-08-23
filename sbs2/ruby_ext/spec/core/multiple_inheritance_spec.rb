require "spec_helper"

describe "Multiple Inheritance" do
  after do
    remove_constants %w(M A M2 B AddedAfterInheritance)
  end

  it "showcase" do
    module M
      def instance_method; end

      class_methods do
        def class_method; end
      end

      inherited do
        attr_accessor :some_accessor
      end
    end

    M.should respond_to(:class_method)

    class A
      inherit M
    end

    A.should respond_to(:class_method)
    A.new.should respond_to(:instance_method)
    A.new.should respond_to(:some_accessor)

    M.directly_included_by.should == {A => true}
  end

  it "should inherit all ancestors class methods" do
    module M
      def instance_method; end

      class_methods do
        def class_method; end
      end
    end

    module M2
      inherit M

      class_methods do
        def class_method2; end
      end
    end

    class B
      inherit M2
    end

    M2.should respond_to(:class_method)

    B.should respond_to(:class_method)
    B.should respond_to(:class_method2)
    B.new.should respond_to(:instance_method)

    M.directly_included_by.should == {M2 => true}
    M2.directly_included_by.should == {B => true}
  end

  it "shouldn't redefine ancestors class methods" do
    module M
      class_methods do
        def class_method; end
      end
    end

    module M2
      inherit M

      class_methods do
        def class_method2; end
      end
    end

    class A
      inherit M
    end

    A.should_not respond_to(:class_method2)
  end

  it "should also allow to explicitly use ClassMethods prototype (from error)" do
    module A
      module ClassMethods
        attr_accessor :callbacks
      end
    end

    class B
      inherit A
    end

    B.should respond_to(:callbacks)
  end

  it "methods defined on base class after inheritance must be propagated to all descendants" do
    module M; end

    class A
      inherit M
    end

    A.instance_methods.should_not include(:method_added_after_inheritance)
    M.send(:define_method, :method_added_after_inheritance){}
    M.instance_methods.should include(:method_added_after_inheritance)
    A.instance_methods.should include(:method_added_after_inheritance)
  end

  it "modules included in base class after inheritance must be propagated to all descendants" do
    module M; end

    class A
      inherit M
    end

    module AddedAfterInheritance
      def module_added_after_inheritance; end
    end

    M.instance_methods.should_not include(:module_added_after_inheritance)
    M.inherit AddedAfterInheritance
    M.instance_methods.should include(:module_added_after_inheritance)
    A.instance_methods.should include(:module_added_after_inheritance)
  end

  it "use case from error" do
    class ItemSpec
    end

    class PageSpec < ItemSpec
    end

    module ::ItemSpecHelper
    end

    module ::PageSpecHelper
    end

    ItemSpec.inherit ItemSpecHelper
    PageSpec.inherit PageSpecHelper
  end
end