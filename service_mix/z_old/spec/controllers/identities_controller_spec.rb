require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Identities" do
  controller_name 'multitenant/identities'
  integrate_views
  
  before :each do
    clear_mail
  end
      
  describe "Signup using Mail and Password" do
    before(:each) do
      login_as User.anonymous
    end
  
    it "enter_email_form" do
      get :enter_email_form
      response.should be_success
    end
  
    it "enter_email" do
      post :enter_email, :token => {:email => "some@mail.com"}
      response.should be_success
      
      Multitenant::EmailVerificationToken.count.should == 1
      token = Multitenant::EmailVerificationToken.first
      
      token.email.should == "some@mail.com"
      
      sent_letters.size.should == 1
      mail = sent_letters.first
      
      mail.body.should include(finish_email_registration_form_identities_path(:token => token.token))
    end
    
    it "finish_email_registration_form" do
      token = Multitenant::EmailVerificationToken.create! :email => "some@mail.com"
      post :finish_email_registration_form, :token => token.token
      response.should be_success
    end
    
    it "finish_email_registration" do
      token = Multitenant::EmailVerificationToken.create! :email => "some@mail.com"
      user_attrs = {:name => "user1", :password => "user1", :password_confirmation => "user1"}
      post :finish_email_registration, :token => token.token, :user => user_attrs
      response.should redirect_to(login_path(:_return_to => nil))      
    end
  end
  
  describe "Registered Users should be able to reset Password" do
    before :each do
      @user = Factory.create :user
    end
  
    it "forgot_password_form" do
      login_as User.anonymous
      get :forgot_password_form
      response.should be_success
    end
  
    it "forgot_password" do
      login_as User.anonymous
      post :forgot_password, :email => @user.email
      
      Multitenant::ForgotPasswordToken.count.should == 1
      token = Multitenant::ForgotPasswordToken.first
      
      sent_letters.size.should == 1
      mail = sent_letters.last      
      mail.body.should include(reset_password_form_identities_path(:token => token.token))
      
      response.should redirect_to(default_path)
    end
    
    it "reset_password_form" do
      token = Multitenant::ForgotPasswordToken.create! :user => @user
      
      login_as User.anonymous
      get :reset_password_form, :token => token.token
      response.should be_success
    end
      
    it "reset_password" do
      token = Multitenant::ForgotPasswordToken.create! :user => @user
      
      login_as User.anonymous
      post :reset_password, :user => {:password => "new password", :password_confirmation => "new password"}, :token => token.token
      response.should redirect_to(login_path(:_return_to => nil))
      
      @user = @user.reload
      @user.should be_authenticated_by_password("new password")      
    end
      
    it "reset_password shouldn't reset password if token is invalid" do
      token = Multitenant::ForgotPasswordToken.create! :user => @user
      
      login_as User.anonymous
      post :reset_password, :user => {:password => "new password", :password_confirmation => "new password"}, :token => 'invalid token'
      response.should redirect_to(default_path)
      
      @user = @user.reload
      @user.should_not be_authenticated_by_password("new password")
    end      
  end
  
  describe "Registered Users should be able to change Password" do
      before :each do
        @user = Factory.create :user
      end
    
    it "update_password_form" do
      login_as @user
      get :update_password_form
      response.should be_success
    end
  
    it "update_password" do
      login_as @user
      post :update_password, :old_password => @user.password, :user => {:password => "new password", :password_confirmation => "new password"}
      response.should redirect_to(default_path)
      @user.should be_authenticated_by_password("new password")
    end
  
    it "Should't allow to change Password if Old Password is Invalid" do
      login_as @user
      post :update_password, :old_password => 'invalid password', :user => {:password => "new password", :password_confirmation => "new password"}
      response.should be_success
      @user.should_not be_authenticated_by_password("new password")
    end
  end
  
  describe "Signup using OpenId" do
    before :each do
      @token = SecureToken.new
      @token[:open_id] = "some_id"
      @token.save!
      
      @return_to = "http://some.com/some".freeze
      @escaped_return_to = "http%3A%2F%2Fsome.com%2Fsome".freeze
      
      login_as User.anonymous
    end
    
    def form_action_should_include_return_to
      Nokogiri::XML(response.body).css("form").first[:action].should include(@escaped_return_to)
    end
    
    it "finish_open_id_registration_form" do
      get :finish_open_id_registration_form, :token => @token.token, :_return_to => @return_to      
      response.should be_success
      form_action_should_include_return_to
    end
    
    it "finish_open_id_registration" do
      post :finish_open_id_registration, :user => {:name => 'user1'}, :token => @token.token, :_return_to => @return_to

      cas_token = SecureToken.first :type => 'cas'
      cas_token.should_not be_nil
      response.should redirect_to(@return_to + "?cas_token=#{cas_token.token}")

      user = User.find_by_name 'user1'
      user.should be_active
      user.should_not be_nil
      User.current.should == user
    end
    
    it "should preserve _return_to if invalid form submited (from error)" do
      post :finish_open_id_registration, :user => {:name => 'invalid name'}, :token => @token.token, :_return_to => @return_to
      response.should be_success
      form_action_should_include_return_to
    end    
  end
end