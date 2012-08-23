require 'spec_helper'

describe "Roles" do
  with_models

  it "user should have its name in roles" do
    user = factory.build :user, name: 'some_name'
    user.roles.should include('user:some_name')
  end

  it "should have correct roles" do
    anonymous = factory.build :anonymous
    anonymous.roles.should == %w{anonymous user user:anonymous}

    user = factory.build :user, name: 'john'
    user.roles.should == %w{registered user user:john}

    admin = factory.build :admin, name: 'john'
    admin.roles.should == %w{admin manager member registered user user:john}
  end

  it "all managers should also have the member role" do
    user = factory.build :manager, name: 'john'
    user.roles.should == %w{manager member registered user user:john}
  end

  it "should have handy methods for checking roles" do
    u = factory.build :anonymous
    u.roles.anonymous?.should be_true
    u.roles.registered?.should be_false
    u.roles.has?(:anonymous).should be_true
    u.should have_role(:anonymous)
  end

  it "should add roles" do
    u = factory.build :member, name: 'john'
    u.should_not have_role('manager')
    u.roles.add :manager
    u.save!
    u.reload
    u.should have_role('manager')
  end

  it "should delete roles" do
    u = factory.build :manager, name: 'john'
    u.roles.delete :member
    u.save!
    u.reload
    u.should_not have_role('manager')
    u.should_not have_role('member')
  end

  it "should add also all lover roles" do
    u = factory.build :user, name: 'john'
    u.roles.should_not include('member')
    u.roles.add :manager
    u.roles.should include('member')
  end

  it "should shrink all roles to major roles" do
    u = factory.build :member, name: 'john'
    u.roles.major.should == %w{member user:john}
  end

  it "should work without space" do
    rad.delete :space
    u = factory.build :user
    u.admin?.should be_false
    rad.include?(:space).should be_false
  end

  # describe "permissions" do
  #   it "should calculate permissions", focus: true do
  #     rad.space = factory.build :space
  #     u = factory.build :global_admin
  #     u.can?('administrate').should be_true
  #   end
  # end
end