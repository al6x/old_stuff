require 'spec_helper'

describe "Spaces" do
  with_models
  login_as :admin
  before do
    @spaces = Controllers::Spaces.new
    @account = factory.create :account
    rad.account = @account
    @space = @account.spaces.first
  end

  it "should display list of spaces" do
    r = @spaces.call :all, account_id: @account.to_param
    r.size.should == 1
    r.first[:name].should == 'default'
  end

  it "should create space" do
    r = @spaces.call :create, account_id: @account.to_param, name: 'new-space'
    r.should_not include(:errors)
    r[:name].should == 'new-space'

    @account.reload
    @account.spaces.size.should == 2
    @account.spaces.last.name.should == 'new-space'
  end

  it "should update space" do
    r = @spaces.call :update, account_id: @account.to_param, id: @space.name, name: 'new-name'
    r.should_not include(:errors)
    r[:name].should == 'new-name'

    @account.reload
    @account.spaces.first.name.should == 'new-name'
  end

  it "should delete space" do
    space = factory.build(:space)
    @account.spaces << space
    @account.save!

    r = @spaces.call :delete, account_id: @account.to_param, id: @space.name
    r.should_not include(:errors)

    @account.reload
    @account.spaces.size.should == 1
  end

  it "non admin shouldn't have access" do
    login_as :manager
    -> {@spaces.call :all}.should raise_error(/Access Denied/)
  end
end