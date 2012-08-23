require "spec_helper"

describe "Prepare Arguments" do

  it "basic parsing" do
    ArgumentsParser.register :m, [:object, :array, :hash]
    ArgumentsParser.parse_arguments_for(:m, :o, 1).should == [:o, [1], {}]
  end

  it "basic method wrapping" do
    class BMWTest
      def add content, options
        :ok
      end
      prepare_arguments_for :add, {type: :object, required: true}, :hash
    end

    BMWTest.new.add('text').should == :ok
  end

  it "except_last_hash for array" do
    ArgumentsParser.register :m, [{type: :array, range: :except_last_hash}, :hash]
    ArgumentsParser.parse_arguments_for(:m, 1, 2, 3, a: :b).should == [[1, 2, 3], {a: :b}]
    # ArgumentsParser.parse_arguments_for(:m, a: :b).should == [[], {a: :b}]
    # ArgumentsParser.parse_arguments_for(:m, 1, 2, 3).should == [[1, 2, 3], {}]
  end

  it "except_last_hash for object" do
    ArgumentsParser.register :m, [{type: :object, range: :except_last_hash}, :hash]
    ArgumentsParser.parse_arguments_for(:m, 1, a: :b).should == [1, {a: :b}]
    ArgumentsParser.parse_arguments_for(:m, a: :b).should == [nil, {a: :b}]
    ArgumentsParser.parse_arguments_for(:m, 1).should == [1, {}]
  end

  it "default value" do
    ArgumentsParser.register :m, [{type: :object, default: ""}]
    ArgumentsParser.parse_arguments_for(:m).should == [""]
  end

  it "string" do
    ArgumentsParser.register :m, [:string]
    ArgumentsParser.parse_arguments_for(:m).should == [""]
  end

end