require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Spaces" do
  controller_name :spaces
  integrate_views

  before :each do        
    set_default_space
    @account = Account.current
    # @account = Factory.create :account
    # set_space @account.spaces.first
    
    @admin = Factory.create :admin
    login_as @admin
  end
  
  it "should display list of spaces" do
    get :index, :account_id => @account.to_param
    response.should be_success
  end
  
  it "should display new dialog" do
    get :new, :account_id => @account.to_param, :format => :js
    response.should be_success
  end
  
  it "should create space" do
    post :create, :account_id => @account.to_param, :format => :js, :space => {:name => 'new_space'}
    response.should be_success
    
    Space.count.should == 2
    Space.all.collect(&:name).sort.should == ['default', 'new_space']
  end
  
  it "should display update dialog" do
    space = @account.spaces.first
    get :edit, :account_id => @account.to_param, :id => space.to_param, :format => :js
    response.should be_success
  end
  
  it "should update space" do
    space = Factory.create :space, :name => 'some_space', :account => @account
    put :update, :account_id => @account.to_param, :id => space.to_param, :format => :js, :space => {:name => 'new_space2', :title => 'new_title'}
    response.should be_success
  
    space.reload
    space.name.should == space.name # sholdn't allow to change name
    space.title.should == 'new_title'
  end
  
  it "should delete space" do
    space = Factory.create :space, :name => 'some_space', :account => @account
    
    delete :destroy, :account_id => @account.to_param, :id => space.to_param, :format => :js
    response.should be_success
    
    @account.reload
    @account.spaces.size.should == 1
  end
  
  it "non admin shouldn't have access" do
    @manager = Factory.create :manager
    login_as @manager
    
    get :index, :account_id => @account.to_param
    response.should be_redirect
  end
end