require 'spec_helper'

describe "Remote Basic" do
  isolate :conveyors

  before do
    rad.conveyors.services do |ss|
      ss.use Rad::Remote::Processors::RemoteCaller, :content
    end
  end

  old_mode = rad.mode
  after :all do
    remove_constants %w(
      BasicSpec
      JsonErrorSpec
      UnregisteredReturnValueSpec
    )

    rad.mode = old_mode, true
  end

  it "basic" do
    class BasicSpec
      inherit Rad::Remote::RemoteController

      def call
        {result: 'some result'}
      end
    end

    workspace = rcall BasicSpec, :call, format: 'json'

    workspace.delete(:remote_object).should be_a(BasicSpec)
    expected_result = {
      params: {format: 'json'},

      class: BasicSpec,
      method_name: :call,

      remote_result: {result: "some result"},
      content: %({"result":"some result"})
    }
    workspace.to_hash(true).subset(expected_result.keys).should == expected_result
  end

  describe "error handling should behave different in :production, :development and :test modes" do
    it "error in :development mode" do
      class JsonErrorSpec
        inherit Rad::Remote::RemoteController

        def call_with_error
          raise 'some error'
        end
      end

      rad.mode = :development, true

      workspace = rcall JsonErrorSpec, 'call_with_error', format: 'json'

      workspace.delete(:remote_object).should be_a(JsonErrorSpec)
      workspace.include?(:remote_result).should be_false
      expected_result = {
        params: {format: 'json'},

        class: JsonErrorSpec,
        method_name: "call_with_error",

        content: %({"error":"some error"})
      }
      workspace.to_hash.subset(expected_result.keys).should == expected_result
    end
  end

  it "should be able to protect methods from GET request"

  it "should not allow unregistered object types be used as return value" do
    class UnregisteredReturnValueSpec
      inherit Rad::Remote::RemoteController

      def call
        Object.new
      end
    end

    lambda{
      rcall UnregisteredReturnValueSpec, 'call', format: 'json'
    }.should raise_error(/You can't use object of type 'Object' as Remote's return value!/)
  end
end