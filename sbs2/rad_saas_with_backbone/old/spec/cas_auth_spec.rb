require 'saas_extensions/users/spec_helper'

describe "CAS Authentication" do
  with_controllers
  with_auth

  before do
    Models::User.current = NotDefined
    @user = Factory.create :user
  end

  describe "Login with CAS" do
    it "should redirect back with CAS token if it's not master domain" do

      return_to = "http://some_domain.com/path"

      pcall(
        Controllers::Sessions, :login,
        {name: @user.name, password: @user.password, _return_to: return_to}
      )

      Models::User.current.should == @user
      token = Models::SecureToken.by_type('cas')
      token.should_not be_nil

      response.should redirect_to(return_to + "?cas_token=#{token.token}")
    end

    it "should redirect back without CAS token if return_to is not master domain" do
      return_to = "/path"

      pcall(
        Controllers::Sessions, :login,
        {name: @user.name, password: @user.password, _return_to: return_to}
      )

      Models::User.current.should == @user
      Models::SecureToken.count(type: 'cas').should == 0

      response.should redirect_to(return_to)
    end

    it "should correctly build return_to url with cas token (from error)" do
      return_to = "http://some_domain.com/path?l=ru" # url with params

      pcall(
        Controllers::Sessions, :login,
        {name: @user.name, password: @user.password, _return_to: return_to}
      )

      token = Models::SecureToken.by_type('cas')
      token.should_not be_nil
      response.should redirect_to(return_to + "&cas_token=#{token.token}")
    end
  end

  describe "Login with CAS token" do
    before do
      set_controller Controllers::Profiles
    end

    it "all non-multitenant controllers should be able to login with CAS token (and then make redirect after login to remove this token)" do
      token = Models::SecureToken.new
      token[:user_id] = @user._id.to_s
      token.save!

      # input url has cas_token
      url_with_cas_token = user_path(@user.to_param, cas_token: token.token)

      call url_with_cas_token do |c|
        c.call

        request.session['user_id'].should == @user._id.to_s

        # redirect to remove cas_token param
        response.location.should include(user_path(@user.to_param))
        response.location.should_not include(token.token)
      end
    end

    it "shouldn't raise error if token is invalid" do
      url_with_cas_token = user_path(@user.to_param, cas_token: 'invalid token')

      call url_with_cas_token do |c|
        c.call
        request.session['user_id'].should == Models::User.anonymous._id.to_s
      end
      response.should redirect_to(user_path(@user.to_param)) # redirect to remove cas_token param
    end
  end

  describe "Logout with CAS token" do
    set_controller Controllers::Sessions

    it "logout action should return cas_logout if it's not master domain" do
      return_to = "http://some_domain.com/path"
      call :logout, _return_to: return_to
      Models::User.current.should == Models::User.anonymous
      response.should redirect_to(return_to + "?cas_logout=true")
    end

    it "logout action shouldn't return cas_logout if it's not master domain" do
      return_to = "/path"
      call :logout, _return_to: return_to
      Models::User.current.should == Models::User.anonymous
      response.should redirect_to(return_to)
    end

    it "logout action should return cas_logout if it's not master domain and even if user already logged out on masterhost" do
      return_to = "http://some_domain.com/path"
      call :logout, _return_to: return_to do |c|
        request.session[:user_id] = @user._id.to_s
        c.call
      end
      Models::User.current.should == Models::User.anonymous
      response.should redirect_to(return_to + "?cas_logout=true")
    end
  end

  describe "Logout with CAS token" do
    it "all non-multitenant controllers should log out if there's cas_logout params" do
      url_with_cas_token = user_path(@user.to_param, cas_logout: 'true', cas_logout: 'true')

      call url_with_cas_token do |c|
        request.session['user_id'] = @user._id.to_s
        c.call

        request.session['user_id'].should == Models::User.anonymous._id.to_s
      end
      response.should redirect_to(user_path(@user.to_param)) # redirect to remove cas_logout param
    end
  end
end