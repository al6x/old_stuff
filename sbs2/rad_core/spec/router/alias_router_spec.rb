require 'spec_helper'

describe "AliasRouter" do
  before_all do
    class SomeController
    end
  end

  after_all{remove_constants :SomeController}

  before{@router = Rad::Router::AliasRouter.new}

  it "encode / decode" do
    @router.add '/login', class_name: 'SomeController', method: :login

    @router.encode!(SomeController, :login, {}).should == ["/login", {}]
    # @router.encode_method('login_path', false).should == [SomeController, :login]
    @router.decode!("/login", {}).should == [SomeController, :login, '/login', {}]
  end

  it "should differentiate aliases with similar path elements" do
    @router.add '/login', class_name: 'SomeController', method: :login
    @router.add '/login/twitter', class_name: 'SomeController', method: :twitter

    @router.encode!(SomeController, :login, {}).should == ["/login", {}]
    @router.decode!("/login", {}).should == [SomeController, :login, '/login', {}]

    @router.encode!(SomeController, :twitter, {}).should == ["/login/twitter", {}]
    @router.decode!("/login/twitter", {}).should == [SomeController, :twitter, '/login/twitter', {}]
  end

  it "input validation" do
    lambda{@router.add :login, class_name: 'SomeController', method: :login}.should raise_error(/\//)
    lambda{@router.add '/login', class_name: 'SomeController'}.should raise_error(/method/)
    lambda{@router.add '/login', method: :login}.should raise_error(/class/)
    lambda{@router.add '/login', class_name: 'SomeController', method: :login, invalid: 'value'}.should raise_error(/unknown/)
    # lambda{@router.add '/login', class_name: 'SomeController', method: :login, url_root: 'users'}.should raise_error(/\//)
  end

  # Deprecated.
  # it "should use :url_root" do
  #   @router.add '/login', class_name: 'SomeController', method: :login, url_root: '/space'
  #
  #   @router.encode(SomeController, :login, {}).should == ["/login", {url_root: '/space'}]
  #   @router.decode("/space/login", {}).should == [SomeController, :login, {}]
  # end

  it "should return nil if route unknown" do
    @router.encode!(SomeController, :unknown, {}).should be_nil
    # @router.encode_method(:unknown_path, false).should be_nil
    @router.decode!("/login", {}).should be_nil
  end

  it 'root alias' do
    @router.add '/', class_name: 'SomeController', method: :home

    @router.encode!(SomeController, :home, {}).should == ["/", {}]
    @router.decode!("/", {}).should == [SomeController, :home, '/', {}]

    # Deprecated.
    # -> {@router.add '/', class_name: 'SomeController', method: :home, url_root: '/space'}.should raise_error(/url_root/)
  end

  describe "prefixes" do
    it "basics" do
      @router.add '/statistics', class_name: 'SomeController', method: :statistics, prefix: [:l, :space]

      @router.encode!(SomeController, :statistics, l: 'en', space: 'personal').should == ["/en/personal/statistics", {}]
      # @router.encode_method("statistics_path", false).should == [SomeController, :statistics]
      @router.decode!("/en/personal/statistics", {}).should ==
        [SomeController, :statistics, '/statistics', {l: 'en', space: 'personal'}]
    end

    it "should also works with path with slashes" do
      @router.add '/blogs/read', class_name: 'SomeController', method: :read, prefix: [:l, :space]

      @router.encode!(SomeController, :read, l: 'en', space: 'personal').should == ["/en/personal/blogs/read", {}]
      @router.decode!("/en/personal/blogs/read", {}).should ==
        [SomeController, :read, '/blogs/read', {l: 'en', space: 'personal'}]
    end

    it "should raise error if prefixes not provided" do
      @router.add '/login', class_name: 'SomeController', method: :login, prefix: :l

      lambda{@router.encode!(SomeController, :login, {})}.should raise_error(/prefix/)
      lambda{@router.decode!('/login', {})}.should raise_error(/prefix/)
    end

    # Deprecated.
    # it "should works with :url_root" do
    #   @router.add '/blogs/read', class_name: 'SomeController', method: :read, prefix: :l, url_root: '/users'
    #
    #   @router.encode(SomeController, :read, l: 'en').should == ["/en/blogs/read", {url_root: '/users'}]
    #   @router.decode("/users/en/blogs/read", {}).should == [SomeController, :read, {l: 'en'}]
    # end
  end
end