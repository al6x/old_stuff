require 'text_utils/spec_helper'

describe "FormatQualifier" do
  before :all do
    class TextProcA < TextUtils::Processor
      def call data, env
        call_next "#{data} a", env
      end
    end

    class TextProcB < TextUtils::Processor
      def initialize processor, text
        super(processor)
        @text = text
      end

      def call data, env
        call_next "#{data} #{@text}", env
      end
    end
  end
  after :all do
    remove_constants :TextProcA, :TextProcB
  end

  before do
    @pipe = TextUtils::Pipe.new \
      TextProcA,
      [TextProcB, 'b']
  end

  it "should process text" do
    @pipe.call('text').should == "text a b"
  end
end