require File.dirname(__FILE__) + '/../spec_helper'

describe "SpaceKeys" do
  
  before :all do
    class ::AnUser
      include MongoMapper::Document
      plugin MongoMapper::Plugins::SpaceKeys
      
      space_key :roles, Array
    end
  end
  
  after :all do
    Object.send :remove_const, :AnUser if Object.const_defined? :AnUser
  end
  
  before :each do
    set_default_space
    @user = AnUser.new
  end
  
  it "shouldn't save empty containers" do
    @user.roles
    @user.space_keys_containers.size.should == 0
  end
  
  it "should correctly save" do
    @user.roles = ['manager']
    @user.space_keys_containers.size.should == 1
    @user.save!
    
    @user = AnUser.find(@user.id)
    @user.roles.should == ['manager']
  end
  
  it "should clean empty containers" do
    @user.roles = ['manager']
    @user.space_keys_containers.size.should == 1
    @user.roles = []
    @user.space_keys_containers.size.should == 0
  end
  
  it "should clean empty containers for saved objects" do
    @user.roles = ['manager']
    @user.save!
    
    @user = AnUser.find @user.id
    @user.roles = []
    @user.space_keys_containers.size.should == 0
  end
  
  it "should works with many spaces" do
    @user.roles = ['manager']
    
    previous_space = Space.current
    space = Factory.build :space    
    Space.current = space
    
    @user.roles.should == []
    @user.roles = ['user']
    
    Space.current = previous_space
    @user.roles.should == ['manager']
  end
end