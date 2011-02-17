require File.dirname(__FILE__) + '/../spec_helper'

class ::AuthorizationsController < ActionController::Base
end

describe "Authorizations" do
  controller_name 'authorizations'
  integrate_views
  
  before :all do
    Space.all
  end
  
  before :each do
    permissions = {
      'call_controller_level' => [],
      'call_business_logic_level' => [],
      'call_with_owner' => []
    }
    Space.stub!(:permissions).and_return(permissions)
    
    class ::AuthorizationsController
      acts_as_authorized
    
      require_permission :call_controller_level, :only => :controller_level
    
      def unprotected
        render :inline => 'ok'
      end
    
      def controller_level
        render :inline => 'ok'
      end
          
      def business_logic_level
        require_permission :call_business_logic_level
        render :inline => 'ok'
      end
      
      def with_owner
        require_permission :call_with_owner, owned_object
        render :inline => 'ok'
      end
      
      def with_owner_controller_level
        render :inline => 'ok'
      end
      require_permission :call_with_owner, :only => :with_owner_controller_level do
        owned_object
      end
      
      protected 
        def owned_object
          @@owned_object
        end
        
        def self.owned_object= o
          @@owned_object = o
        end
    end
    AuthorizationsController.owned_object = nil
    
    @user = User.new
    User.stub!(:current).and_return(@user)    
  end
  
  after :each do
    Object.remove_const(:AuthorizationsController) rescue{}
  end
  
  it "should allow to call unprotected methods" do    
    get :unprotected
    response.should be_success
    response.body.should == 'ok'
  end
  
  it "should allow declarative authorization at controller level" do    
    @user.stub!(:can?).and_return(false)
    get :controller_level
    response.should be_redirect
  
    @user.stub!(:can?).and_return(true)
    get :controller_level
    response.should be_success
    response.body.should == 'ok'
  end
  
  it "should allow declarative authorization at business logic level" do    
    @user.stub!(:can?).and_return(false)
    get :business_logic_level
    response.should be_redirect
  
    @user.stub!(:can?).and_return(true)
    get :business_logic_level
    response.should be_success
    response.body.should == 'ok'
  end
  
  it "should use owner if provided" do
    @user.stub!(:can?){false}
    get :with_owner
    response.should be_redirect

    
    o = Object.new
    o.stub!(:owner_name){@user.name}
    AuthorizationsController.owned_object = o 
    
    @user.stub!(:can?) do |operation, object|       
      object and object.owner_name == @user.name
    end
    
    get :with_owner
    response.should be_success
    response.body.should == 'ok'    
  end
  
  it "should use owner if provided (action level)" do    
    @user.stub!(:can?){false}
    get :with_owner_controller_level
    response.should be_redirect
    
    
    o = Object.new
    o.stub!(:owner_name){@user.name}
    AuthorizationsController.owned_object = o
  
    @user.stub!(:can?) do |operation, object|       
      object and object.owner_name == @user.name
    end
    
    get :with_owner_controller_level
    response.should be_success
    response.body.should == 'ok'    
  end
end