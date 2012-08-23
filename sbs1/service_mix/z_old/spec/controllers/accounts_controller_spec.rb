require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Accounts" do
  controller_name 'multitenant/accounts'
  integrate_views

  before :each do    
    set_space nil
    
    @admin = Factory.create :global_admin
    login_as @admin
  end
  
  it "should display list of accounts" do   
    Factory.create :account
    get :index
    response.should be_success
  end
  
  it "should display new dialog" do
    get :new, :format => :js
    response.should be_success
  end
  
  it "should create account" do
    post :create, :format => :js, :account => {:name => 'new-account'}
    response.should be_success

    Account.count.should == 1
    account = Account.first
    account.name.should == 'new-account'
    account.domains.should == ['new-account.localhost']
    account.spaces.size.should == 1
    account.spaces.first.name.should == 'default'
  end
  
  it "should display update dialog" do
    account = Factory.create :account
    get :edit, :id => account.id, :format => :js
    response.should be_success
  end
  
  it "shouldn't allow to update account name" do
    account = Factory.create :account, :name => 'some-account'
    
    attributes = {:name => 'some-account2', :domains_as_string => "#{account.domains_as_string}\nnew_domain.com"}
    put :update, :id => account.id, :format => :js, :account =>  attributes
    response.should be_success
    
    Account.count.should == 1
    account = Account.first
    account.name.should == 'some-account'
    account.domains.sort.should == ['new_domain.com', 'some-account.localhost']
    account.spaces.size.should == 1
    account.spaces.first.name.should == 'default'    
  end
  
  it "should delete account" do
    account = Factory.create :account
    
    delete :destroy, :id => account.id, :format => :js
    response.should be_success
    
    Account.count.should == 0
  end
  
  it "non global_admin shouldn't have access" do
    space = Factory.create :space, :name => 'some_space'
    set_space space    
    
    non_global_admin = Factory.create :admin
    login_as non_global_admin
    
    set_space nil
    
    get :index
    response.should be_redirect
  end
end