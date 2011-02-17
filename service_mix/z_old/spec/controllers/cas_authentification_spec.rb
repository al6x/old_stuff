require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "CAS Authentication" do
  
  before :each do
    $do_not_skip_authentication = true
    User.current = nil
    
    @user = Factory.create :user
  end
  
  after :each do
    $do_not_skip_authentication = false
  end
  
  describe "Login with CAS" do
    controller_name 'multitenant/sessions'
    integrate_views
  
    it "should redirect back with CAS token if it's not master domain" do
      return_to = "http://some_domain.com/path"
      
      post :login, :name => @user.name, :password => @user.password, :_return_to => return_to
      
      User.current.should == @user
      token = SecureToken.first(:type => 'cas')
      token.should_not be_nil      
      
      response.should redirect_to(return_to + "?cas_token=#{token.token}")
    end
    
    it "should redirect back without CAS token if return_to is not master domain" do
      return_to = "/path"
      
      post :login, :name => @user.name, :password => @user.password, :_return_to => return_to
      
      User.current.should == @user
      SecureToken.count(:type => 'cas').should == 0
      
      response.should redirect_to(return_to)
    end        
    
    it "should correctly build return_to url with cas token (from error)" do
      return_to = "http://some_domain.com/path?l=ru" # url with params
      
      post :login, :name => @user.name, :password => @user.password, :_return_to => return_to
      
      token = SecureToken.first(:type => 'cas')
      token.should_not be_nil
      response.should redirect_to(return_to + "&cas_token=#{token.token}")      
    end
  end
  
  describe "Login with CAS token" do
    controller_name 'users'
    integrate_views
    
    before :all do
      set_default_space
    end
    
    it "all non-multitenant controllers should be able to login with CAS token" do
      token = SecureToken.new
      token[:user_id] = @user.id.to_s
      token.save!
      
      get :show, :id => @user.name, :cas_token => token.token
      response.should redirect_to(user_path(@user.to_param)) # redirect to remove cas_token param
      
      response.session[:user_id].should == @user.id.to_s
    end
    
    it "shouldn't raise error if token is invalid" do
      get :show, :id => @user.name, :cas_token => 'invalid token'
      response.should redirect_to(user_path(@user.to_param)) # redirect to remove cas_token param
      response.session[:user_id].should == User.anonymous.id.to_s
    end
  end
  
  describe "Logout with CAS token" do
    controller_name 'multitenant/sessions'
    integrate_views 
    
    it "logout action should return cas_logout if it's not master domain" do
      return_to = "http://some_domain.com/path"      
      delete :logout, :_return_to => return_to      
      User.current.should == User.anonymous
      response.should redirect_to(return_to + "?cas_logout=true")
    end
    
    it "logout action shouldn't return cas_logout if it's not master domain" do
      return_to = "/path"      
      delete :logout, :_return_to => return_to      
      User.current.should == User.anonymous
      response.should redirect_to(return_to)
    end
    
    it "logout action should return cas_logout if it's not master domain and even if user already logged out on masterhost" do
      @request.session[:user_id] = @user.id.to_s
      
      return_to = "http://some_domain.com/path"      
      delete :logout, :_return_to => return_to      
      User.current.should == User.anonymous
      response.should redirect_to(return_to + "?cas_logout=true")
    end
  end
  
  describe "Logout with CAS token" do
    controller_name 'users'
    integrate_views
    
    before :all do
      set_default_space
    end
    
    it "all non-multitenant controllers should log out if there's cas_logout params" do
      @request.session[:user_id] = @user.id.to_s
      get :show, :id => @user.name, :cas_logout => 'true'
      
      response.should redirect_to(user_path(@user.to_param)) # redirect to remove cas_logout param
      
      response.session[:user_id].should == User.anonymous.id.to_s
    end
  end
end