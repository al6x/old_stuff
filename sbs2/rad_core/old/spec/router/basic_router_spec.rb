require 'spec_helper'

describe "RedirectRouter" do
  before do
    @router = Rad::Router::BasicRouter.new
  end

  it "skip" do
    @router.skip(/\/fs/)

    halt = catch :halt do
      @router.decode("/users/all", {})
      nil
    end
    halt.should be_nil

    halt = catch :halt do
      @router.decode("/fs/user/avatar", {})
      nil
    end
    halt.should_not be_nil
  end

  it "redirect" do
    workspace = Rad::Conveyors::Workspace.new
    workspace.response = Rad::Http::Response.new
    @router.stub!(:workspace).and_return(workspace)

    @router.redirect(/^\/([^\/]+)$/, "/\\1/Items")

    halt = catch :halt do
      @router.decode("/default/Items", {})
      nil
    end
    halt.should be_nil

    halt = catch :halt do
      @router.decode("/default", {})
      nil
    end
    halt.should_not be_nil
    workspace.response.headers['Location'].should == '/default/Items'
  end
end