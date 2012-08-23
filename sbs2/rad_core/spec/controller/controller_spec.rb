require 'spec_helper'

describe "Controller" do
  after{remove_constants :Tmp}

  it "action and callback order, arguments passing and return value" do
    class Tmp
      inherit Rad::Controller

      around do |controller, block|
        controller.before_show
        result = block.call
        controller.after_show
        result
      end

      def show arg1, arg2
        do_show arg1, arg2
      end
    end

    c = Tmp.new
    c.callback_proxy?.should be_true
    c.should_receive(:before_show).ordered
    c.should_receive(:do_show).with('arg1', 'arg2').ordered.and_return(:ok)
    c.should_receive(:after_show).ordered
    c.show('arg1', 'arg2').should == :ok
  end
end