require 'spec_helper'

describe "Http" do
  with_view_path "#{spec_dir}/views"

  isolate :conveyors

  before do
    rad.conveyors.web do |web|
      web.use Rad::Http::Processors::HttpWriter
      web.use Rad::Controller::Processors::ControllerCaller
    end
  end

  after :all do
    remove_constants %w(
      ContentTypeSpec
      StatusSpec
      StatusShortcutsSpec
      LocationSpec
      RequestMethod
      ForbidGetSpec
      ViewVariablesSpec
    )
  end

  describe 'render' do
    it "should take :content_type option" do
      class ::ContentTypeSpec
        inherit Rad::Controller::Http

        def action
          render inline: "some content", content_type: Mime.js
        end
      end

      wcall(ContentTypeSpec, :action)
      response.content_type.should == "application/javascript"
    end

    it "should take :status option" do
      class ::StatusSpec
        inherit Rad::Controller::Http

        def action
          render inline: "some content", status: 220
        end
      end

      wcall(StatusSpec, :action)
      response.status.should == 220
    end

    it "should take shortcuts to status codes" do
      class ::StatusShortcutsSpec
        inherit Rad::Controller::Http

        def ok
          render :ok
        end

        def failed
          render :failed
        end
      end

      wcall(StatusShortcutsSpec, :ok)
      response.status.should == 200

      wcall(StatusShortcutsSpec, :failed)
      response.status.should == 500
    end

    it "should take :location option" do
      class ::LocationSpec
        inherit Rad::Controller::Http

        def action
          render location: "/"
        end
      end

      # mock
      class ::LocationSpec
        def redirect_to location
          self.class.location = location
        end

        class << self
          attr_accessor :location
        end
      end

      wcall(LocationSpec, :action, format: 'html')
      LocationSpec.location.should == '/'
    end
  end

  it "should specify request method" do
    class ::RequestMethod
      inherit Rad::Controller::Http
      def action
        request.post?.should == true
      end
    end

    workspace, params = {env: {'REQUEST_METHOD' => 'POST'}}, {}
    wcall(RequestMethod, :action, workspace, params)
  end

  it "should protect methods from GET request" do
    class ::ForbidGetSpec
      inherit Rad::Controller::Http
      allow_get_for :get_action

      def get_action; end
      def post_action; end
    end

    workspace = {env: {'REQUEST_METHOD' => 'GET'}}

    wcall(ForbidGetSpec, :get_action, workspace, {})
    lambda{
      wcall(ForbidGetSpec, :post_action, workspace, {})
    }.should raise_error(/not allowed/)
  end

  it "request and response must be availiable in view" do
    class ::ViewVariablesSpec
      inherit Rad::Controller::Http

      def action
        @instance_variable = "iv value"
      end
    end

    wcall(ViewVariablesSpec, :action).should == %(\
request: true
response: true)
  end
end