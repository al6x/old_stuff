require 'spec_helper'

describe "Account" do
  with_models

  it "should create default space" do
    factory.create :account, name: 'new-account'
    Models::Account.count.should == 1
    account = Models::Account.first
    account.name.should == 'new-account'
    account.domains.should == ['new-account.localhost']
    account.spaces.size.should == 1
    account.spaces.first.name.should == 'default'
  end
end