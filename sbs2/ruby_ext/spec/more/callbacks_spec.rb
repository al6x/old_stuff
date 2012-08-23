require 'spec_helper'

describe "Callbacks" do
  after{remove_constants :SomeClass, :AnotherClass}

  describe 'basic' do
    before do
      class SomeClass
        inherit RubyExt::Callbacks

        set_callback :save, :before, :before_save
        set_callback :save, :around, :around_save
        set_callback :save, :after, :after_save

        protected
          def around_save
            around_save_called
            yield
          end
      end
    end

    it "basic" do
      o = SomeClass.new
      o.should_receive :before_save
      o.should_receive :around_save_called
      o.should_receive :after_save
      o.run_callbacks(:save, :some_method){"result"}.should == "result"
    end

    it "should be possible to call before & after separatelly (in this mode :around is not available)" do
      o = SomeClass.new
      o.should_receive :before_save
      o.run_before_callbacks :save, :some_method
      o.should_receive :after_save
      o.run_after_callbacks :save, :some_method
    end

    it "inheritance" do
      class AnotherClass < SomeClass
        set_callback :save, :before, :before_save2
      end

      o = AnotherClass.new
      o.should_receive :before_save
      o.should_receive :before_save2
      o.should_receive :around_save_called
      o.should_receive :after_save
      o.run_callbacks(:save, :some_method){"result"}.should == "result"
    end
  end

  it "blocks" do
    class SomeClass
      inherit RubyExt::Callbacks

      set_callback(:save, :before){|controller| controller.result << :before}
      set_callback :save, :around do |controller, block|
        begin
          controller.result << :around_begin
          block.call
        ensure
          controller.result << :around_end
        end
      end
      set_callback(:save, :after){|controller| controller.result << :after}

      def result
        @result ||= []
      end
    end

    o = SomeClass.new
    o.run_callbacks(:save, :some_method){"result"}.should == "result"
    o.result.should == [:before, :around_begin, :after, :around_end]
  end

  it "execution order" do
    class SomeClass
      inherit RubyExt::Callbacks

      # order is important, don't change it
      set_callback :save, :before, :before1
      set_callback :save, :after,  :after1
      set_callback :save, :around, :around1
      set_callback :save, :before, :before2

      protected
        def around1
          around1_called
          yield
        end
    end

    o = SomeClass.new
    o.should_receive(:before1).ordered.once
    o.should_receive(:around1_called).ordered.once
    o.should_receive(:before2).ordered.once
    o.should_receive(:after1).ordered.once
    o.run_callbacks :save, :some_method
  end

  it 'terminator' do
    class SomeClass
      inherit RubyExt::Callbacks

      set_callback :save, :before, :before_save, terminator: false
      set_callback :save, :before, :before_save2

      def method
        run_callbacks :save, :some_method do
          "result"
        end
      end

      protected
        def before_save
          false
        end
    end

    o = SomeClass.new
    o.should_not_receive :before_save2
    o.run_callbacks(:save, :some_method){"result"}.should_not == "result"
  end

  it 'conditions' do
    class SomeClass
      inherit RubyExt::Callbacks

      set_callback :save, :before, :before_save, only: :another_method
    end

    o = SomeClass.new
    o.should_not_receive :before_save
    o.run_callbacks(:save, :some_method){"result"}.should == 'result'

    o = SomeClass.new
    o.should_receive :before_save
    o.run_callbacks(:save, :another_method){"result"}.should == 'result'
  end

  it "if, unless conditions" do
    c = RubyExt::Callbacks::AbstractCallback.new
    c.conditions = {if: lambda{|target, inf| true}}
    c.run?(nil, :some_method, {}).should be_true

    c.conditions = {if: lambda{|target, inf| false}}
    c.run?(nil, :some_method, {}).should be_false

    c.conditions = {unless: lambda{|target, inf| true}}
    c.run?(nil, :some_method, {}).should be_false

    c.conditions = {unless: lambda{|target, inf| false}}
    c.run?(nil, :some_method, {}).should be_true
  end

  it "only, except conditions" do
    c = RubyExt::Callbacks::AbstractCallback.new
    c.conditions = {only: :a}
    c.run?(nil, :a, {}).should be_true

    c.conditions = {only: :b}
    c.run?(nil, :a, {}).should be_false

    c.conditions = {except: :a}
    c.run?(nil, :a, {}).should be_false

    c.conditions = {except: :b}
    c.run?(nil, :a, {}).should be_true

    c.conditions = {only: :a}
    c.run?(nil, :a, {}).should be_true
  end


  it "around callback should be able to change result value" do
    class SomeClass
      inherit RubyExt::Callbacks

      set_callback :save, :around, :around_save

      def around_save
        yield
        'another result'
      end
    end

    o = SomeClass.new
    o.run_callbacks(:save, :some_method){"result"}.should == 'another result'
  end

  describe "wrapping methods in callbacks" do
    it "wrap_method_with_callbacks" do
      class SomeClass
        inherit RubyExt::Callbacks

        set_callback :save, :before, :before_save

        def update
          'ok'
        end

        wrap_method_with_callbacks :update, :save
      end

      o = SomeClass.new
      o.should_receive(:before_save).once
      o.update.should == 'ok'
    end

    it "wrap_with_callbacks" do
      class SomeClass
        inherit RubyExt::Callbacks
        def update; end

        should_receive(:wrap_method_with_callbacks).with(:update, :save)
        wrap_with_callback :save
      end
    end

    it "callbacks for method with super call should be called only once" do
      class SomeClass
        inherit RubyExt::Callbacks

        set_callback :save, :before, :before_save

        def update
          'ok'
        end
        wrap_method_with_callbacks :update, :save
      end

      class AnotherClass < SomeClass
        def update
          super
          'ok2'
        end
        wrap_method_with_callbacks :update, :save
      end

      o = AnotherClass.new
      o.should_receive(:before_save).once
      o.update.should == 'ok2'
    end

    it "callbacks should be runned only once" do
      class SomeClass
        inherit RubyExt::Callbacks

        set_callback :save, :before, :before_save
      end

      o = SomeClass.new
      o.should_receive(:before_save).once
      (o.run_callbacks :save, :some_method do
        o.run_callbacks :save, :some_method do
          'result'
        end
      end).should == 'result'
    end
  end
end