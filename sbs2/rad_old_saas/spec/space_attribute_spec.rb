require 'spec_helper'

describe "SpaceAttributes" do
  with_models

  before :all do
    class ::AnUser
      inherit Mongo::Model, Models::SpaceAttribute

      space_attribute :roles, default: [], standalone: [] # type: Array,
    end
  end

  after :all do
    remove_constants :AnUser
  end

  before do
    @user = AnUser.new
    rad.space
  end

  it "shouldn't save empty containers" do
    @user.roles
    @user.space_roles.size.should == 0
  end

  it "should correctly save" do
    @user.roles = ['manager']
    @user.space_roles.size.should == 1
    @user.save!

    @user.reload
    @user.roles.should == ['manager']
  end

  it "should clean empty containers" do
    @user.roles = ['manager']
    @user.space_roles.size.should == 1
    @user.roles = []
    @user.space_roles.size.should == 0
  end

  it "should clean empty containers for saved objects" do
    @user.roles = ['manager']
    @user.save!

    @user.reload
    @user.roles = []
    @user.space_roles.size.should == 0
  end

  it "should works with many spaces" do
    @user.roles = ['manager']

    previous_space = Models::Space.current
    space = Factory.build :space
    Models::Space.current = space

    @user.roles.should == []
    @user.roles = ['user']

    Models::Space.current = previous_space
    @user.roles.should == ['manager']
  end

  it "should work without space" do
    rad.delete :space
    @user.roles
  end
end