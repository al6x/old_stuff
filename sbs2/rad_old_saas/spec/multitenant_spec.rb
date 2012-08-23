require 'spec_helper'

describe "Accounts" do
  with_controllers

  before :all do
    class ::TheAppController
      inherit Rad::Controller::Http

      inherit Rad::Controller::Multitenant
      around :set_account_and_space_without_spec
      def set_account_and_space
        yield
      end

      def action
        TheAppController.check.call if TheAppController.check
      end

      def self.check &b
        b ? @b = b : @b
      end
    end
  end

  after :all do
    remove_constants :TheAppController
  end

  before do
    @account = rad.account
    @account.domains = ['test.com']
    @account.save!
    @space = @account.spaces.first

    rad.delete :account
    rad.delete :space

    set_controller TheAppController
  end

  it "should select account and space" do
    TheAppController.check do
      Models::Account.current.should == @account
      Models::Space.current.should == @space
    end
    call :action
    response.should be_ok
  end

  it "should raise error if there's no account" do
    @account.domains = []
    @account.save!
    lambda{call :action}.should raise_error(/no Account/)
  end

  it 'should select :default account if it exist' do
    @account.domains = []
    @account.save!

    default_account = Factory.create :account, name: 'default'
    default_space = default_account.spaces.first

    TheAppController.check do
      Models::Account.current.should == default_account
      Models::Space.current.should == default_space
    end

    call :action
    response.should be_ok
  end

  it 'should select :space on :default account if it exist' do
    @account.domains = []
    @account.save!

    default_account = Factory.create :account, name: 'default'
    default_space = Factory.create :space, name: 'news', account_id: default_account._id

    TheAppController.check do
      Models::Account.current.should == default_account
      Models::Space.current.should == default_space
    end

    lambda{call :action, space: 'invalid'}.should raise_error(/no 'invalid' Space/)

    call :action, space: 'news'
    response.should be_ok
  end
end