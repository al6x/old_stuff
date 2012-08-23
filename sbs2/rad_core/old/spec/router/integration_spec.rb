require 'spec_helper'

describe "Router Integration" do
  before :all do
    class ::AnRemote
      def call; end
    end
  end

  isolate :conveyors, :router

  after :all do
    remove_constants %w(AnRemote)
  end

  before do
    rad.conveyors.web.use Rad::Router::Processors::Router, :class_variable, :method_variable
    rad.router.routers = [
      [:simple_router, Rad::Router::SimpleRouter.new]
    ]
  end

  def call_router path, params
    rad.conveyors.web.call path: path, params: Rad::Conveyors::Params.new(params)
  end

  it "basic" do
    workspace = call_router '/an_remote/call', format: 'json'

    expected_result = {
      path: "/an_remote/call",
      params: {format: 'json'},

      class_variable: AnRemote,
      method_variable: :call
    }
    workspace.to_hash(true).subset(expected_result.keys).should == expected_result
  end

  it "params must be casted to string" do
    workspace = call_router '/an_remote/call', a: 'b'
    workspace.params.to_hash.subset(:a).should == {a: 'b'}
  end

  it "default router should raise error if route is invalid" do
    lambda{call_router '/invalid/call', format: 'json'}.should raise_error(/uninitialized constant Invalid/)
  end
end