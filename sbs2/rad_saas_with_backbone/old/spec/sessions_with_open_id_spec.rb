require 'saas_extensions/users/spec_helper'

describe "Authentication" do
  with_controllers
  with_auth

  before do
    Models::User.current = NotDefined
    @return_to = "http://some.com/some".freeze
  end

  describe "Login by OpenID" do
    it "if user exists login" do
      open_id = "http://some_id.com"

      user = Factory.build :user
      user.open_ids << open_id
      user.save!

      pcall Controllers::Sessions, :login, openid_identifier: open_id, _return_to: @return_to

      token = Models::SecureToken.by_type('cas')
      token.should_not be_nil
      response.should redirect_to(@return_to + "?cas_token=#{token.token}")

      Models::User.current.should == user
    end
  end

  describe "Log Out" do
    it "Registered Users should be able to Log Out" do
      user = Factory.create :user
      Models::User.current = user
      call Controllers::Sessions, :logout, _return_to: @return_to
      response.should redirect_to(@return_to + "?cas_logout=true")

      Models::User.current.should == Models::User.anonymous
    end
  end

end