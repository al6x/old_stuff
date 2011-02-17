require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Authentication" do
  
  def form_action_should_include_return_to
    Nokogiri::XML(response.body).css("form").first[:action].should include(@escaped_return_to)
  end
  
  before :each do
    $do_not_skip_authentication = true
    User.current = nil
    @return_to = "http://some.com/some".freeze
    @escaped_return_to = "http%3A%2F%2Fsome.com%2Fsome".freeze
  end
  
  after :each do
    $do_not_skip_authentication = false
  end
  
  describe "By defautl should logged in as Anonymous" do
    controller_name 'multitenant/pages'
    integrate_views
    
    it do
      get :index
      User.current.should == User.anonymous
    end
  end
  
  describe "Login by Password" do
    controller_name 'multitenant/sessions'
    integrate_views
  
    it "Should display Log In Form" do
      get :login, :_return_to => @return_to
      response.should be_success
      form_action_should_include_return_to
    end
  
    it "Registered Users should be able to Log In" do
      user = Factory.create :user
      post :login, :name => user.name, :password => user.password, :_return_to => @return_to
      response.location.start_with?(@return_to).should be_true
      User.current.should == user
    end
  
    it "Users shuldn't be able to login with invalid password" do
      user = Factory.create :user
      post :login, :name => user.name, :password => 'invalid', :_return_to => @return_to
      response.should be_success
      form_action_should_include_return_to
      User.current.should == User.anonymous
    end
  
    it "Not activated users should'not be able to login" do
      user = Factory.create :new_user
      post :login, :name => user.name, :password => user.password, :_return_to => @return_to
      response.should be_success
      form_action_should_include_return_to
      User.current.should == User.anonymous
    end    
  end
  
  describe "Login by OpenID" do
    controller_name "multitenant/sessions"
    integrate_views
    
    it "if user doesn't exists redirect to registration" do      
      post :login, :openid_identifier => "http://some_id.com", :_return_to => @return_to
      
      token = SecureToken.first
      token.should_not be_nil
      
      response.should redirect_to(finish_open_id_registration_form_identities_path(:token => token.token, :_return_to => @return_to))
    end
    
    it "if user exists login" do  
      open_id = "http://some_id.com"
          
      user = Factory.build :user
      user.open_ids << open_id
      user.save!
      
      post :login, :openid_identifier => open_id, :_return_to => @return_to
      
      token = SecureToken.first :type => 'cas'
      token.should_not be_nil
      response.should redirect_to(@return_to + "?cas_token=#{token.token}")
      
      User.current.should == user
    end
  end
  
  describe "Log Out" do
    controller_name 'multitenant/sessions'
    integrate_views
    
    it "Registered Users should be able to Log Out" do
      user = Factory.create :user
      User.current = user
      get :logout, :_return_to => @return_to
      response.should redirect_to(@return_to + "?cas_logout=true")
      
      User.current.should == User.anonymous
    end
    
    it "Should not loose session variables (from error)" do
      controller.session[:variable] = true
      get :login
      controller.session[:variable].should be_true
    end
  end
  
  describe "Set Cookie Token" do
    controller_name 'multitenant/sessions'
    integrate_views
          
    it "should set remember me token" do
      user = Factory.create :user
      post :login, :name => user.name, :password => user.password      
      
      SecureToken.count.should == 1
      token = SecureToken.first
      token[:user_id].should == user.id.to_s
      
      response.cookies['auth_token'].should == token.token
    end
  end
  
  describe "Restore user from Cookie Token" do
    controller_name 'multitenant/pages'
    integrate_views
    
    it "any action in multitenant controller" do
      user = Factory.create :user
      
      token = SecureToken.new
      token[:user_id] = user.id.to_s
      token.expires_at = 2.weeks.from_now
      token.save!
            
      @request.cookies['auth_token'] = token.token
      get :index
  
      User.current.name.should == user.name
    end
  end
end