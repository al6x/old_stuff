require 'spec_helper'

describe "User" do
  with_models

  it "should create blank user" do
    user = factory.build(:blank_user)
    user.should_not be_valid
    user.should be_inactive
  end

  it "user should be valid" do
    user = factory.create :user
    user.should be_valid
  end

  describe "Authentication" do
    it "should not authenticate registered but inactive user" do
      user = factory.build(:new_user)
      user.crypted_password.should_not be_blank
      user.should be_valid
      user.should be_inactive
      user.should_not be_authenticated_by_password(user.password)
      Models::User.authenticate_by_password(user.name, user.password).should be_nil
    end

    it "should authenticate registered user" do
      user = factory.create :user
      user.should be_authenticated_by_password(user.password)
      Models::User.authenticate_by_password(user.name, user.password).should == user
    end

    it "should not allow same email" do
      user = factory.build :user
      user.email = "some@email.com"
      user.save.should be_true

      user = factory.build :user
      user.email = "some@email.com"
      user.save.should be_false
      user.errors[:email].should_not be_blank
    end

    it "should update password" do
      user = factory.create :user
      user.update_password('invalid', 'new_password', 'new_password').should be_false
      user.update_password(user.password, 'new_password', 'new_password').should be_true
    end
  end
end