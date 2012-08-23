require 'spec_helper'

describe "Core" do
  with_load_path spec_dir
  isolate :conveyors, :router, before: :all

  before :all do
    rad.web

    rad.router.routers = [
      [:simple_router, Rad::Router::SimpleRouter.new]
    ]
  end

  after :all do
    remove_constants %w(
      SmokeTestSpec
      JsonFormatSpec
      RequestAndSessionSpec
      FullUrl
    )
  end

  it "smoke test" do
    class ::SmokeTestSpec
      inherit Rad::Controller::Http

      def action
        respond_to do |format|
          format.json{render json: {a: 'b'}}
          format.html{render inline: "some content"}
        end
      end
    end

    wcall("/smoke_test_spec/action")
    response.body.should == %(some content)

    wcall("/smoke_test_spec/action", format: 'json')
    response.body.should == %({"a":"b"})
  end

  it "full url (from error)" do
    class ::FullUrl
      inherit Rad::Controller::Http

      def action
        params.a.should == 'b'
        render inline: 'ok'
      end
    end

    wcall "http://localhost/full_url/action?a=b" do |c|
      check = {
        'PATH_INFO'    => '/full_url/action',
        'QUERY_STRING' => 'a=b'
      }
      workspace.env.subset(check.keys).should == check
      c.call
    end
    response.body.should == %(ok)
  end

  it "json" do
    class ::JsonFormatSpec
      inherit Rad::Controller::Http

      def action
        render json: {a: 'b'}
      end
    end

    wcall("/json_format_spec/action.json")
    response.body.should == %({"a":"b"})
    # response.rson.should == {'result' => 'value'}
  end

  it "should have workspace, request, env, and session" do
    class ::RequestAndSessionSpec
      inherit Rad::Controller::Http

      inject :workspace
      def action
        workspace.should_not == nil
        workspace.env.should_not == nil
        request.should_not == nil
        request.session.should_not == nil

        self.class.request_and_session_passed = true

        render json: {a: 'b'}
      end

      class << self
        attr_accessor :request_and_session_passed
      end
    end

    wcall('/request_and_session_spec/action.json')
    RequestAndSessionSpec.request_and_session_passed.should be_true
  end
end