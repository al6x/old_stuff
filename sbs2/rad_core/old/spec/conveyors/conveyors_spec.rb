require 'spec_helper'

describe "Conveyor" do
  inject :conveyors

  def call_conveyor
    r = conveyors.web.call(result: [])
    r.result
  end

  after :all do
    remove_constants %w(
      SmokeTestASpec
      SmokeTestBSpec
      CommonCaseASpec
      CommonCaseBSpec
      NotCatchedErrorSpec
      ErrorInAfterBlockASpec
      ErrorInAfterBlockBSpec
      ErrorBubblingASpec
      ErrorBubblingBSpec
    )
  end

  isolate :conveyors

  before :all do
    rad.mode = :development, true
  end

  after :all do
    rad.mode = :test, true
  end

  it "smoke test" do
    class SmokeTestASpec < Rad::Conveyors::Processor
      def call
        workspace.result << :a_before
        next_processor.call
        workspace.result << :a_after
      end
    end

    class SmokeTestBSpec < Rad::Conveyors::Processor
      def call
        rad.workspace.result << :b_before
        next_processor.call
        rad.workspace.result << :b_after
      end
    end

    conveyors.web.use SmokeTestASpec
    conveyors.web.use SmokeTestBSpec
    call_conveyor.should == [:a_before, :b_before, :b_after, :a_after]
  end

  describe "error handling" do
    it "common case" do
      class CommonCaseASpec < Rad::Conveyors::Processor
        def call
          workspace.result << :a_before

          begin
            next_processor.call
          rescue StandardError => e
            workspace.result << e.message
          end
        end
      end

      class CommonCaseBSpec < Rad::Conveyors::Processor
        def call
          workspace.result << :b_before
          raise 'error before'
        end
      end

      conveyors.web.use CommonCaseASpec
      conveyors.web.use CommonCaseBSpec
      call_conveyor.should == [:a_before, :b_before, "error before"]
    end

    it "should raise error if not catched" do
      class NotCatchedErrorSpec < Rad::Conveyors::Processor
        def call
          workspace.result << :before
          raise 'error before'
        end
      end

      conveyors.web.use NotCatchedErrorSpec
      lambda{call_conveyor}.should raise_error(/error before/)
    end

    it "in after block" do
      class ErrorInAfterBlockASpec < Rad::Conveyors::Processor
        def call
          workspace.result << :a_before

          begin
            next_processor.call
          rescue StandardError => e
            workspace.result << e.message
          end
        end
      end


      class ErrorInAfterBlockBSpec < Rad::Conveyors::Processor
        def call
          workspace.result << :b_before
          next_processor.call
          raise 'error after'
        end
      end


      conveyors.web.use ErrorInAfterBlockASpec
      conveyors.web.use ErrorInAfterBlockBSpec
      call_conveyor.should == [:a_before, :b_before, "error after"]
    end

    it "bubbling (from error)" do
      class ErrorBubblingASpec < Rad::Conveyors::Processor
        def call
          begin
            next_processor.call
          rescue RuntimeError => e
            workspace.result << e.message
          end
        end
      end

      class ErrorBubblingBSpec < Rad::Conveyors::Processor
        def call
          raise 'error'
        end
      end

      conveyors.web.use ErrorBubblingASpec
      conveyors.web.use ErrorBubblingBSpec

      call_conveyor.should == ['error']
    end
  end
end