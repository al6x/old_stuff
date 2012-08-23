require 'spec_helper'

describe "Http Router" do
  before do
    @router = Rad::Http::Router.new
    @router.routers = [Rad::Router::ResourceRouter.new]
    @router.configure do |c|
      c.resource :blogs, class_name: 'Blogs'
    end
    @router.formatter = Rad::Router::DotFormat.new

    class Blogs; end
  end
  after{remove_constants :Blogs}

  describe "build_url" do
    it "should convert params to json if specified" do
      @router.build_url(Blogs, :all, a: :b, as_json: true).should ==
        %(/blogs?json=%7B%22a%22%3A%22b%22%7D)
    end

    it "should works with full url" do
      @router.build_url('http://google.com').should == "http://google.com"
    end

    it "should not allow to use url_root/params/format with full url (http://)" do
      lambda{@router.build_url('http://google.com', {a: 'b'})}.should raise_error(/can't use params/)
    end

    it "should escape params" do
      @router.build_url(Blogs, :all, a: 'b/c').should == "/blogs?a=b%2Fc"
      @router.build_url('/login', a: 'b/c').should == "/login?a=b%2Fc"
    end

    it "should encode string paths" do
      @router.build_url('/some_path', key: :value).should == "/some_path?key=value"
      @router.build_url('/some_path').should == "/some_path"
    end

    it "shouldn't modify arguments (from error)" do
      options = {format: :js}
      @router.build_url(Blogs, :all, options).should == "/blogs.js"
      options.should == {format: :js}
    end

    it "should encode url root" do
      @router.root = '/app'
      @router.build_url(Blogs, :all).should == "/app/blogs"
      @router.build_url('/login').should == "/app/login"
    end

    it "should encode format" do
      @router.build_url(Blogs, :all, format: 'json').should == "/blogs.json"
      @router.build_url('/login', format: 'json').should == "/login.json"
    end
  end
end