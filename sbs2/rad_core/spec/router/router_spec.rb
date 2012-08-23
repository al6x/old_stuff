require 'spec_helper'

describe "Router" do
  before_all do
    class ::Blogs
      def read; end
    end
  end
  after_all{remove_constants :Blogs}

  describe "basic" do
    before do
      @stub = Object.new
      @router = Rad::Router.new @stub
      @router.formatter = Rad::Router::DotFormat.new
      @router.root = '/app'
    end

    it "encode" do
      @stub.should_receive(:encode!).
        with(Blogs, :read, {lang: 'en', format: 'json'}).
        and_return(['/en/blogs/read', {format: 'json'}])
      @router.encode(Blogs, :read, {lang: 'en', format: 'json'}).should == ['/app/en/blogs/read.json', {}]
    end

    it "decode" do
      @stub.should_receive(:decode!).
        with('/en/blogs/read', {format: 'json'}).
        and_return([Blogs, :read, '/blogs/read', {lang: 'en', format: 'json'}])
      @router.decode("/app/en/blogs/read.json", {}).should ==
        [Blogs, :read, '/blogs/read', {lang: 'en', format: 'json'}]
    end
  end

  # describe "miscellaneous" do
  #   before do
  #     @router = Rad::Router.new
  #     @router.routers = [Rad::Router::ResourceRouter.new]
  #     @router.configure do |c|
  #       c.resource :blogs, class_name: 'Blogs'
  #     end
  #     @router.formatter = Rad::Router::DotFormat.new
  #     @router.root = '/app'
  #
  #     class Blogs; end
  #   end
  #   after{remove_constants :Blogs}
  #
  #
  #   it "decode should remove :root and :format from path" do
  #     @router.decode('/app/blogs/read.json', {})
  #   end
  # end
end