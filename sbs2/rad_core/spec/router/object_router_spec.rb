require 'spec_helper'

describe "ObjectRouter" do
  before_all do
    class ::Blogs
    end
  end

  after_all{remove_constants :Blogs}

  before do
    @router = Rad::Router::ObjectRouter.new
  end

  describe 'Singleton Resource' do
    before do
      @router.configure(
        default_class_name: 'Blogs',
        class_to_resource: -> klass      {klass.name},
        resource_to_class: -> resource   {resource.constantize;},
        id_to_class:       -> id, params {nil}
      )
    end

    it "basic" do
      @router.encode!(Blogs, :some, {}).should == ["/Blogs/some", {}]
      # @router.encode_method('some_blog_path', false).should == [Blogs, :some]
      # @router.encode_method('some_blogs_path', false).should == [Blogs, :some]
      @router.decode!("/Blogs/some", {}).should == [Blogs, :some, '/Blogs/some', {}]
    end

    it "by default should use :all method if the method not explicitly specified" do
      @router.encode!(Blogs, :all, {}).should == ["/Blogs", {}]
      @router.encode!(Blogs, nil, {}).should == ["/Blogs", {}]
      # @router.encode_method('blog_path', false).should == [Blogs, :all]
      # @router.encode_method('blogs_path', false).should == [Blogs, :all]
      @router.decode!("/Blogs", {}).should == [Blogs, :all, '/Blogs', {}]
    end
  end

  describe "Object Resource" do
    before do
      @router.configure(
        default_class_name: 'Blogs',
        id_to_class:       -> id, params {id == 'about' ? Blogs : nil},
        resource_to_class: -> resource   {resource.constantize}
      )
    end

    # TODO3 remove also class from :encode, use:
    #
    # @router.encode('about', :update, view: 'full').should == ["/about/update", {view: 'full'}]
    # @router.encode_method('update_path').should == [:update]
    #
    it "basic" do
      @router.encode!(Blogs, :update, id: 'about', view: 'full').should == ["/about/update", {view: 'full'}]
      # @router.encode_method('update_path', true).should == [Blogs, :update]
      @router.decode!("/about/update", {view: 'full'}).should ==
        [Blogs, :update, '/about/update', {id: 'about', view: 'full'}]
    end

    it "by default should use :read method if the method not explicitly specified" do
      @router.encode!(Blogs, :read, id: 'about', view: 'full').should == ["/about", {view: 'full'}]
      @router.encode!(Blogs, nil, id: 'about', view: 'full').should == ["/about", {view: 'full'}]
      # @router.encode_method('path', true).should == [Blogs, :read]
      @router.decode!("/about", {view: 'full'}).should ==
        [Blogs, :read, '/about', {id: 'about', view: 'full'}]
    end

    it "should raise error if :class for :id is not resolved" do
      lambda{@router.decode!("/non-existing-id", {view: 'full'})}.should raise_error(/no class for .* id/)
    end
  end

  describe "prefixes" do
    before do
      @common_options = {
        default_class_name: 'Blogs',
        class_to_resource: -> klass      {klass.name},
        resource_to_class: -> resource   {resource.constantize},
        id_to_class:       -> id, params {id == 'about' ? Blogs : nil}
      }
    end

    it "class resource" do
      @router.configure @common_options.merge(prefix: [:l, :space])

      @router.encode!(Blogs, :some, l: 'en', space: 'personal').should == ["/en/personal/Blogs/some", {}]
      @router.encode!(Blogs, :all, l: 'en', space: 'personal').should == ["/en/personal/Blogs", {}]
      @router.decode!("/en/personal/Blogs/some", {}).should ==
        [Blogs, :some, '/Blogs/some', {l: 'en', space: 'personal'}]
      @router.decode!("/en/personal/Blogs", {}).should ==
        [Blogs, :all, '/Blogs', {l: 'en', space: 'personal'}]
    end

    it "object resource" do
      @router.configure @common_options.merge(prefix: [:l, :space])

      @router.encode!(Blogs, :update, id: 'about', l: 'en', space: 'personal').should == ["/en/personal/about/update", {}]
      @router.encode!(Blogs, nil, id: 'about', l: 'en', space: 'personal').should == ["/en/personal/about", {}]
      @router.decode!("/en/personal/about/update", {}).should ==
        [Blogs, :update, '/about/update', {id: 'about', l: 'en', space: 'personal'}]
      @router.decode!("/en/personal/about", {}).should ==
        [Blogs, :read, '/about', {id: 'about', l: 'en', space: 'personal'}]
    end

    it "should raise error if prefixes not provided" do
      @router.configure @common_options.merge(prefix: :l)

      lambda{@router.encode!(Blogs, :some, {})}.should raise_error(/prefix/)
      lambda{@router.encode!(Blogs, :all, {})}.should raise_error(/prefix/)
      lambda{@router.decode!('/Blogs/some', {})}.should raise_error(/no class for .* id/)
      lambda{@router.decode!('/Blogs', {})}.should raise_error(/invalid 'size' of path/)


      lambda{@router.encode!(Blogs, :update, id: 'about')}.should raise_error(/prefix/)
      lambda{@router.encode!(Blogs, :read, id: 'about')}.should raise_error(/prefix/)
      lambda{@router.decode!('/about/update', {})}.should raise_error(/no class for .* id/)
      lambda{@router.decode!('/about', {})}.should raise_error(/invalid 'size' of path/)
    end

    # Deprecated.
    # it "should works with :url_root" do
    #   @router.configure @common_options.merge(prefix: [:l], url_root: '/users')
    #
    #   @router.encode(Blogs, :some, l: 'en').should == ["/en/Blogs/some", {url_root: '/users'}]
    #   @router.decode("/users/en/Blogs/some", {}).should == [Blogs, :some, {l: 'en'}]
    #
    #   @router.encode(Blogs, :update, id: 'about', l: 'en').should == ["/en/about/update", {url_root: '/users'}]
    #   @router.decode("/users/en/about/update", {}).should == [Blogs, :update, {id: 'about', l: 'en'}]
    # end
  end

  describe "miscellaneous check" do
    before{@common_options = {default_class_name: 'Blogs'}}

    # it "should raise if :id and not default class " do
    #   @router.configure @common_options
    #   lambda{@router.encode(Blogs, :some, id: 'about')}.should raise_error(/:id can't be used with :class/)
    # end

    # Deprecated.
    # it "should return nil if resource name is not in plural form" do
    #   @router.configure @common_options
    #   lambda{@router.decode!('/Blog/some', {})}.should raise_error(/resource must be in plural form/)
    # end

    it "object id should not start with capital letter" do
      @router.configure @common_options
      lambda{@router.encode!(Blogs, :some, {id: 'About'})}.should raise_error(/capital/)
    end

    it "resource name should be uppercased" do
      @router.configure @common_options.merge(class_to_resource: -> klass {'blogs'})
      lambda{@router.encode!(Blogs, :some, {})}.should raise_error(/capital/)
    end

    it "should not be allowed to called twice" do
      @router.configure @common_options
      lambda{@router.configure @common_options}.should raise_error(/twice/)
    end

    # Deprecated.
    # it "should allow only plural form in resource names" do
    #   @router.configure @common_options.merge(class_to_resource: -> klass {'Blog'})
    #   lambda{@router.encode!(Blogs, :some, {})}.should raise_error(/plural/)
    # end

    it "shouldn't allow slashes in resource name" do
      @router.configure @common_options.merge(class_to_resource: -> klass {'Site/Blog'})
      lambda{@router.encode!(Blogs, :some, {})}.should raise_error(/\//)
    end

    # Deprecated.
    # it "should correctly works with unknown routes" do
    #   @router.encode(Blogs, :read, {}).should be_nil
    #   @router.encode_method('read_blog_path').should be_nil
    #   @router.encode_method('read_blogs_path').should be_nil
    #   @router.decode("/Blogs/read", {}).should be_nil
    #
    #   @router.encode(Blogs, :read, id: 'about', view: 'full').should be_nil
    #   @router.encode_method('read_blog_path').should be_nil
    #   @router.encode_method('read_blogs_path').should be_nil
    #   @router.decode("/Blogs/about/read", view: 'full').should be_nil
    # end
  end
end