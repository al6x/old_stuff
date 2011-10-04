require File.dirname(__FILE__) + '/../spec_helper'

describe "User" do
  
  it "blank user" do
    user = Factory.build(:blank_user)
    user.should_not be_valid
    user.should be_inactive
  end
  
  describe "Authentication by Password" do  
    it "registering user" do
      user = Factory.build(:new_user)
      user.crypted_password.should_not be_blank
      user.should be_valid
      user.should be_inactive      
      user.should be_authenticated_by_password(user.password)
    end
    
    it "authentication" do
      user = Factory.create :user
      User.authenticate_by_password(user.name, user.password).should == user
    end
    
    it "email uniquiness" do
      user = Factory.build :user
      user.email = "some@email.com"
      user.save.should be_true
      
      user = Factory.build :user
      user.email = "some@email.com"
      user.save.should be_false
      user.errors.on(:email).should_not be_blank
    end
    
    it "update_password" do
      user = Factory.create :user
      user.update_password('new_password', 'new_password', 'invalid').should be_false
      user.update_password('new_password', 'new_password', user.password).should be_true
    end
  end  
  
  describe "Authentication by OpenID" do
    it "registering user" do
      user = Factory.build(:blank_user)
      user.open_ids << "open_id"
      user.crypted_password.should be_blank
      user.should be_valid
      user.should be_inactive
      
      user.save.should be_true
      user.reload
      user.crypted_password.should be_blank
    end
    
    it "authentication" do
      user = Factory.create :open_id_user
      User.authenticate_by_open_id(user.open_ids.first).should == user
    end
    
    it "open_id uniquiness" do
      user = Factory.build :open_id_user
      user.open_ids = ['some_id']
      user.save.should be_true
      
      user = Factory.build :open_id_user
      user.open_ids = ['some_id']
      user.save.should be_false
      user.errors.on(:open_ids).should_not be_blank
    end
  end
  
  it "add password to OpenID" do
    user = Factory.create :open_id_user
    user.update_password('new_password', 'new_password', '').should be_true
    user.save.should be_true
    User.authenticate_by_password(user.name, user.password).should == user
  end
end