require 'spec_helper'

describe "Accounts" do
  with_models
  login_as :global_admin
  before{@accounts = Controllers::Accounts.new}

  it "should display account" do
    account = factory.create :account, name: 'some-domain'
    @accounts.call(:show, id: account.name).should == [account.to_rson(:protected)]
  end

  it "should display list of accounts" do
    a = factory.create :account
    @accounts.call(:all).should == [a.to_rson(:protected)]
  end

  it "should create account" do
    r = @accounts.call :create, name: 'new-account'
    r[:name].should == 'new-account'
    r.should_not include(:errors)

    Models::Account.count.should == 1
    account = Models::Account.first
    account.name.should == 'new-account'
  end

  it "should update account" do
    account = factory.create :account, name: 'some-domain'

    r = @accounts.call :update, id: account.name, name: 'new-domain'
    r[:name].should == 'new-domain'
    r.should_not include(:errors)

    account = Models::Account.first
    account.name.should == 'new-domain'
  end

  it "should delete account" do
    account = factory.create :account, name: 'some-domain'

    r = @accounts.call :delete, id: account.name
    r.should_not include(:errors)

    Models::Account.count.should == 0
  end

  it "non global_admin shouldn't have access" do
    login_as :admin
    -> {@accounts.call :all}.should raise_error(/Access Denied/)
  end
end