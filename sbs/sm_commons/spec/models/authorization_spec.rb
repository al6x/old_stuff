require File.dirname(__FILE__) + '/../spec_helper'

describe "Authorization" do
  
  before :each do
    set_default_space
  end
  
  describe "Roles" do
    it "normalization" do
      Role.normalize_roles(%w{manager member specific_role user:user1}).should == %w{member specific_role user:user1}
    end
    
    it "denormalization to higher roles" do
      Role.denormalize_to_higher_roles(%w{member specific_role user:user1}).should == %w{manager member specific_role user:user1}
    end
    
    it "denormalization to lower roles" do
      Role.denormalize_to_lower_roles(%w{member specific_role user:user1}).should == %w{member specific_role user user:user1}
    end
            
    it "user should have it's name in roles" do
      user = Factory.build :user, :name => 'some_name'
      user.roles.include?('user:some_name').should be_true
    end
    
    it ":anonymous, :registered, :user roles" do
      anonymous = Factory.build :anonymous
      anonymous.roles.should == %w{anonymous user user:anonymous}
    
      user = Factory.build :user, :name => 'name'
      user.roles.should == %w{registered user user:name}
    
      admin = Factory.build :admin, :name => 'john'
      admin.roles.should == %w{admin manager member registered user user:john}
    end
      
    it "all managers should also have the member role, always" do
      user = Factory.build :manager, :name => 'john'
      user.roles.should == %w{manager member registered user user:john}
    end
      
    it "handy methods" do
      u = User.anonymous      
      u.roles.anonymous?.should be_true
      u.roles.registered?.should be_false
      u.roles.has?(:anonymous).should be_true
      u.should have_role(:anonymous)
    end
      
    it "add_role" do
      u = Factory.create :member
      u.should_not have_role('manager')
      u.add_role :manager
      u.save!
      u.reload
      u.should have_role('manager')
    end    
    
    it "remove_role" do
      u = Factory.create :manager
      u.remove_role :member
      u.save!
      u.reload
      u.should_not have_role('manger')
      u.should_not have_role('member')
    end
    
    it "should add also all lover roles" do
      u = Factory.create :user
      u.roles.should_not include('member')
      u.add_role :manager
      u.roles.should include('member')
    end
    
    it "special case, admin role" do
      u = Factory.create :user
      u.should_not have_role('manager')
      u.add_role :admin
      u.save!
      u.reload
      u.should have_role('admin')
      u.should have_role('manager')
    end
    
    it "major_roles" do
      u = Factory.create :member, :name => 'aname'
      u.add_role :director
      u.major_roles.should == %w{director member user:aname}
    end
  end
end