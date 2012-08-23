require 'spec_helper'

describe "Authentication" do
  with_models

  before do
    @controller = Controllers::Sessions.new

    @rack_request = Rad::Http::RackRequest.new({})
    @request = Rad::Http::Request.new @rack_request
    @response = Rad::Http::Response.new

    rad.stub!(:request).and_return @request
    rad.stub!(:response).and_return @response

    @user = factory.create :user
  end

  describe "login" do
    login_as :anonymous

    it "should login user" do
      @rack_request.stub!(:post?).and_return false
      @controller.call(:login).should be_nil

      @rack_request.stub!(:post?).and_return true
      @response.should_receive(:set_cookie)
      r = @controller.call :login, name: @user.name, password: @user.password
      r[:name].should == @user.name
    end

    it "should not login user with invalid password" do
      @rack_request.stub!(:post?).and_return true
      r = @controller.call :login, name: @user.name, password: 'invalid password'
      r.should include(:errors)
    end

    it "should not login inactive users" do
      user = factory.create :new_user
      @rack_request.stub!(:post?).and_return true
      r = @controller.call :login, name: user.name, password: user.password
      r.should include(:errors)
    end
  end

  describe "logout" do
    before{login_as @user}

    it "should log out users" do
      @rack_request.stub!(:post?).and_return true
      @response.should_receive(:delete_cookie)
      @controller.call :logout
    end
  end
end