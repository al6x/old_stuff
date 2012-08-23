require 'spec_helper'

describe "UrlHelper" do
  isolate :conveyors, :router, before: :all

  before :all do
    rad.web

    class ControllerStub
      inherit Rad::ControllerRoutingHelper, Rad::ControllerMiscellaneousHelper

      def build_url *args
        args.first
      end
    end
  end

  after :all do
    remove_constants :ControllerStub
  end

  before do
    @c = ControllerStub.new
  end

  def stub_workspace
    @response = Rad::Http::Response.new
    @params = Rad::Conveyors::Params.new

    @workspace = Object.new
    @workspace.stub(:params).and_return(@params)
    @workspace.stub(:response).and_return(@response)

    @c.stub(:workspace).and_return(@workspace)
  end

  def within_request &block
    @response.body = catch(:halt){block.call}
  end

  describe "redirect_to" do
    before do
      stub_workspace
    end

    it "html format" do
      @params.format = 'html'

      within_request{@c.redirect_to('/some_book')}
      @response.status.should == 302
      @response.headers['Location'].should == "/some_book"
      @response.body.should =~ /You are being/
    end

    it "full url, special case (from error)" do
      @params.format = 'html'

      within_request{@c.redirect_to('http://localhost/some_book')}
      @response.status.should == 302
      @response.headers['Location'].should == "http://localhost/some_book"
      @response.body.should =~ /You are being/
    end

    it "js format" do
      @params.format = 'js'

      within_request{@c.redirect_to('/some_book')}
      @response.status.should == 200
      @response.headers['Location'].should be_blank
      @response.body_as_string.should == "window.location = '/some_book';"
    end
  end

  describe "reload_page" do
    before do
      stub_workspace
    end

    it "basic" do
      @params.format = 'js'

      within_request{@c.reload_page}
      @response.status.should == 200
      @response.body_as_string.should =~ /reload/
    end
  end
end