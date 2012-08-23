require 'spec_helper'

describe "Users" do
  with_models
  before do
    @user = factory.create :user
    @users = Controllers::Users.new
  end

  it "should show list of users (to anyone)" do
    login_as :anonymous
    @users.call(:all).should == [@user.to_rson(:public)]
  end

  it "should show user (to anyone)" do
    login_as :anonymous
    @users.call(:read, id: @user.to_param).should == @user.to_rson(:public_full)
  end

  it "should update user" do
    login_as @user
    r = @users.call :update, id: @user.to_param, first_name: 'New Name'
    @user.reload
    @user.first_name.should == 'New Name'
    r.should == @user.to_rson(:public_full)
  end

  it "should add role" do
    login_as :manager
    r = @users.call :add_role, id: @user.to_param, role: 'member'
    @user.reload
    @user.member?.should be_true
    r.should == @user.to_rson(:public_full)
  end

  it "should delete role" do
    login_as :manager
    @user = factory.create :member
    r = @users.call :delete_role, id: @user.to_param, role: 'member'
    @user.reload
    @user.member?.should be_false
    r.should == @user.to_rson(:public_full)
  end
end