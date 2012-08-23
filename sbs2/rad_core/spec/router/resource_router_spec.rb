require 'spec_helper'

describe "Resource Router" do
  before_all do
    class ::Blogs
      def read; end
    end
  end

  after_all{remove_constants :Blogs}

  before do
    @router = Rad::Router::ResourceRouter.new
  end

  describe 'core' do
    it "should recognize resource" do
      @router.add :blogs, class_name: 'Blogs'

      @router.encode!(Blogs, :update, id: '10', view: 'full').should == ["/blogs/10/update", {view: 'full'}]
      # @router.encode_method('update_blog_path', true).should == [Blogs, :update]
      # @router.encode_method('update_blogs_path', true).should == [Blogs, :update]
      @router.decode!("/blogs/10/update", {view: 'full'}).should ==
        [Blogs, :update, '/blogs/10/update', {id: '10', view: 'full'}]
    end

    it "should recognize singleton methods" do
      @router.add :blogs, class_name: 'Blogs', singleton_methods: [:count]

      @router.encode!(Blogs, :count, {}).should == ["/blogs/count", {}]
      # @router.encode_method('count_blog_path', false).should == [Blogs, :count]
      # @router.encode_method('count_blogs_path', false).should == [Blogs, :count]
      @router.decode!("/blogs/count", {}).should == [Blogs, :count, '/blogs/count', {}]
    end

    it "should use default method names" do
      @router.add :blogs, class_name: 'Blogs'

      @router.encode!(Blogs, :all, {}).should == ["/blogs", {}]
      @router.encode!(Blogs, nil,  {}).should == ["/blogs", {}]
      @router.decode!("/blogs", {}).should == [Blogs, :all, '/blogs', {}]

      @router.encode!(Blogs, :read, id: '10', view: 'full').should == ["/blogs/10", {view: 'full'}]
      @router.encode!(Blogs, nil,   id: '10', view: 'full').should == ["/blogs/10", {view: 'full'}]
      @router.decode!("/blogs/10", {view: 'full'}).should ==
        [Blogs, :read, '/blogs/10', {id: '10', view: 'full'}]
    end
  end

  describe "prefixes" do
    it "should recognize resource without id" do
      @router.add :blogs, class_name: 'Blogs', prefix: [:l, :space], singleton_methods: [:count]

      @router.encode!(Blogs, :count, l: 'en', space: 'personal').should == ["/en/personal/blogs/count", {}]
      @router.decode!("/en/personal/blogs/count", {}).should ==
        [Blogs, :count, '/blogs/count', {l: 'en', space: 'personal'}]
    end

    it "should recognize resource with id" do
      @router.add :blogs, class_name: 'Blogs', prefix: [:l, :space]

      @router.encode!(Blogs, :update, id: '10', l: 'en', space: 'personal').should == ["/en/personal/blogs/10/update", {}]
      @router.decode!("/en/personal/blogs/10/update", {}).should ==
        [Blogs, :update, '/blogs/10/update', {id: '10', l: 'en', space: 'personal'}]
    end

    it "should raise error on encode and return nil on decode if prefix not provided" do
      @router.add :blogs, class_name: 'Blogs', prefix: :l, singleton_methods: [:count]

      lambda{@router.encode!(Blogs, :count, {})}.should raise_error(/not provided :l prefix/)
      @router.decode!('/blogs/count', {}).should be_nil

      lambda{@router.encode!(Blogs, :update, id: '10')}.should raise_error(/not provided :l prefix/)
      @router.decode!('/blogs/10/update', {}).should be_nil
    end

    it "should be able to use alias for prefix parameter" do
      @router.add :blogs, class_name: 'Blogs', prefix: [:l, :space_id], singleton_methods: [:count]

      @router.encode!(Blogs, :count, l: 'en', space_id: 'personal').should == ["/en/personal/blogs/count", {}]
      @router.decode!("/en/personal/blogs/count", {}).should ==
        [Blogs, :count, '/blogs/count', {l: 'en', space_id: 'personal'}]
    end

    it "should work with default methods" do
      @router.add :blogs, class_name: 'Blogs', prefix: :l

      @router.encode!(Blogs, :all, l: 'en').should == ["/en/blogs", {}]
      @router.decode!("/en/blogs", {}).should == [Blogs, :all, '/blogs', {l: 'en'}]

      @router.encode!(Blogs, :read, id: '10', l: 'en').should == ["/en/blogs/10", {}]
      @router.decode!("/en/blogs/10", {}).should ==
        [Blogs, :read, '/blogs/10', {id: '10', l: 'en'}]
    end
  end

  describe "miscellaneous check" do
    # Rejected.
    # it "should allow only plural form in resource definition" do
    #   lambda{@router.add :blog, class_name: 'Blogs'}.should raise_error(/plural/)
    #   @router.add :blogs, class_name: 'Blogs'
    # end

    it "shouldn't allow slashes in resource name" do
      lambda{@router.add '/admin/blogs', class_name: 'Blogs'}.should raise_error(/\//)
    end

    it "should return nil if route is unknown" do
      @router.encode!(Blogs, :count, {}).should be_nil
      # @router.encode_method('count_blog_path', false).should be_nil
      # @router.encode_method('count_blogs_path', false).should be_nil
      @router.decode!("/blogs/count", {}).should be_nil

      @router.encode!(Blogs, :update, id: '10', view: 'full').should be_nil
      # @router.encode_method('update_blog_path', true).should be_nil
      # @router.encode_method('update_blogs_path', true).should be_nil
      @router.decode!("/blogs/10/update", view: 'full').should be_nil
    end

    it "should validate input" do
      lambda{@router.add :blogs, class_name: 'Blogs', invalid: 'value'}.should raise_error(/unknown options/)
      lambda{@router.add :blogs}.should raise_error(/no class name/)
    end

    it "should raise error when encoding unknown singleton method" do
      @router.add :blogs, class_name: 'Blogs'
      lambda{@router.encode!(Blogs, :count, {}).should == ["/blogs/count", {}]}.
        should raise_error(/there's no :count method in the list of singleton methods/)
    end

    it "should work with empty resource" do
      @router.add nil, class_name: 'Blogs', singleton_methods: [:count, :all]

      @router.encode!(Blogs, :update, id: '10', view: 'full').should == ["/10/update", {view: 'full'}]

      @router.decode!("/count", {}).should == [Blogs, :count, '/count', {}]
      @router.decode!("/", {}).should == [Blogs, :all, '/', {}]
      @router.decode!("/10", {}).should == [Blogs, :read, '/10', {id: '10'}]
      @router.decode!("/10/update", {view: 'full'}).should ==
        [Blogs, :update, '/10/update', {id: '10', view: 'full'}]
    end
  end
end