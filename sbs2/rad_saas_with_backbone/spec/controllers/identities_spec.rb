require 'spec_helper'

describe "Identities" do
  with_models
  before{@controller = Controllers::Identities.new}

  describe "creating new user" do
    login_as :anonymous

    it "should generate email confirmation token" do
      response = @controller.call :generate_email_confirmation_token, email: 'some@mail.com'
      response[:email].should == 'some@mail.com'

      Models::User::EmailVerificationToken.count.should == 1
      token = Models::User::EmailVerificationToken.first
      token.email.should == "some@mail.com"

      rad.mailer.sent_letters.size.should == 1
      letter = rad.mailer.sent_letters.first

      params = {host: rad.http.host, token: token.token, l: rad.locale.current, }
      url = rad.http_router.build_url '/finish_registration', params
      letter.body.should include(url)
    end

    it "should create user" do
      token = Models::User::EmailVerificationToken.create! email: "some@mail.com"
      response = @controller.call :create_user,
        token: token.token, name: "user1", password: "user1", password_confirmation: "user1"
      response[:name].should == 'user1'
    end
  end

  describe "resetting password" do
    login_as :anonymous
    before{@user = factory.create :user}

    it "should generate password reset token" do
      r = @controller.call :generate_reset_password_token, email: @user.email
      r.should == {}

      Models::User::ResetPasswordToken.count.should == 1
      token = Models::User::ResetPasswordToken.first

      rad.mailer.sent_letters.size.should == 1
      letter = rad.mailer.sent_letters.first

      url = rad.http_router.build_url '/reset_password', host: rad.http.host, token: token.token
      letter.body.should include(url)
    end

    it "should reset password" do
      token = Models::User::ResetPasswordToken.create! user: @user
      r = @controller.call :reset_password,
        token: token.token,
        password: "new password", password_confirmation: "new password"
      r.should == {}

      @user.reload
      @user.should be_authenticated_by_password("new password")
    end

    it "should not reset password if token is invalid" do
      token = Models::User::ResetPasswordToken.create! user: @user
      r = @controller.call :reset_password,
        token: 'invalid token',
        password: "new password", password_confirmation: "new password"
      r.should include(:errors)

      @user.reload
      @user.should_not be_authenticated_by_password("new password")
    end
  end

  describe "updating password" do
    before do
      @user = factory.create :user
      login_as @user
    end

    it "should update password" do
      r = @controller.call :update_password,
        old_password: @user.password,
        password: "new password", password_confirmation: "new password"
      r.should == {}
      @user.should be_authenticated_by_password("new password")
    end

    it "should't update password if old password is invalid" do
      r = @controller.call :update_password,
        old_password: 'invalid old password',
        password: "new password", password_confirmation: "new password"
      r.should include(:errors)
      @user.should_not be_authenticated_by_password("new password")
    end
  end
end