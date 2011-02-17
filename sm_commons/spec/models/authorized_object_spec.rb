require File.dirname(__FILE__) + '/../spec_helper'

describe "Authorized Object" do  
  before :all do
    class ::AModel
      include MongoMapper::Document
      plugin MongoMapper::Plugins::AuthorizedObject
      acts_as_authorized_object
    end
  end
  
  after :all do
    Object.send :remove_const, :AModel if Object.const_defined? :AModel
  end
  
  before :each do 
    set_default_space
  end
  
  describe "Owner, Viewers, Collaborators" do
    before :each do
      @user = Factory.create :user, :name => 'auser'
      User.current = nil
    end
    
    it "should be abel to create objects (from error)" do
      User.current = @user
      o = AModel.new
      o.save!
    end 
      
    it "should by default set current user_name as owner_name if there is current user" do
      o = AModel.new
      o.owner_name.should be_nil
    
      User.current = @user
      o = AModel.new
      o.owner_name.should == 'auser'
    end
      
    it "owner" do
      o = AModel.new
      o.owner = @user
      o.owner_name.should == @user.name 
      o.viewers.should == %w{manager user:auser}       
      o.should be_valid
    end
      
    it 'viewers' do
      o = AModel.new
      o.owner = @user
      o.add_viewer :user
      o.viewers.should == %w{manager member user user:auser}
      o.should be_valid
    
      o.remove_viewer :user
      o.viewers.should == %w{manager user:auser}
      o.should be_valid
    
      o.add_viewer :member
      o.viewers.should == %w{manager member user:auser}
      o.should be_valid
    
      o.add_viewer :user
      o.viewers.should == %w{manager member user user:auser}
      o.should be_valid
    end
    
    it "duplicate roles (from error)" do
      o = AModel.new
      o.owner = @user
      o.save!
      
      o = AModel.first # don't use reload, it willn't catch this error
      o.viewers.should == %w{manager user:auser}
    end
  
    it "collaborators" do
      o = AModel.new
      o.owner = @user
      o.add_collaborator :member
      o.collaborators.should == %w{member}
      o.should be_valid
  
      Space.current.custom_roles << 'director'
      o.add_collaborator :director
      o.collaborators.should == %w{member director}
      o.should be_valid
  
      o.remove_collaborator :member
      o.collaborators.should == %w{director}
      o.should be_valid
    end
    
    it "normalized_collaborators" do
      o = AModel.new
      o.owner = @user
      o.add_collaborator :member
      o.normalized_collaborators.should == %w{manager member user:auser}
    end
    
    it "viewers and collaborators dependance" do
      o = AModel.new
      o.owner = @user
      o.add_collaborator :user
      o.collaborators.should == %w{user}
      o.viewers.should == %w{manager member user user:auser}
      o.should be_valid
      
      o.remove_viewer :member
      o.viewers.should == %w{manager user user:auser}
      o.collaborators.should == %w{user}
      
      o.remove_viewer :user
      o.viewers.should == %w{manager user:auser}
      o.collaborators.should == %w{}
    end
    
    it "major viewers" do
      o = AModel.new
      o.owner = @user
      o.add_viewer :member
      o.add_viewer :director
      o.viewers.should == %w{director manager member user:auser}
      o.minor_viewers.should == %w{director member user:auser}
    end
    
    it "collaborators should be able to change object (from error)" do
      col = Factory.create :member, :name => 'collaborator'
      
      o = AModel.new
      o.owner = @user      
      col.can?(:update, o).should be_false
      
      o.add_collaborator :member
      o.clear_cache
      col.can?(:update, o).should be_true
      @user.can?(:update, o).should be_true
      
      o.save!
      o = AModel.find o.id
      col.can?(:update, o).should be_true
      @user.can?(:update, o).should be_true
    end
  end
  
  describe "Permissions" do
    before :each do
      Space.stub!(:permissions).and_return('manage' => %w{manager})
    end
    
    describe "General" do
      before :each do
        Space.stub!(:permissions).and_return('manage' => %w{manager})
      end
            
      it "should also works without mulititenancy" do
        Space.current = nil
        Account.current = nil
        u = User.new
        u.can?(:manage, AModel)
      end
      
      it "should works for new user" do
        u = User.new
        u.can?(:manage, AModel)
      end
    
      it 'permissions' do
        u = Factory.create :user
        u.can?(:manage, AModel).should be_false
      
        u = Factory.create :manager
        u.can?(:manage, AModel).should be_true
      end    
    end
    
    describe "as Owner" do
      before :each do
        Space.stub!(:permissions).and_return('manage' => %w{manager owner})
        @user = Factory.create :user
        
        @object = AModel.new
        
        @owned_object = AModel.new
        @owned_object.owner = @user
      end
  
      it "owner?" do
        @user.should_not be_owner(@object)
        @user.should be_owner(@owned_object)        
      end
  
      it 'permissions for owner' do
        @user.can?(:manage, @object).should be_false
        @user.can?(:manage, @owned_object).should be_true
      end
    end
    
    describe "Special :view permission" do
      before :each do 
        Space.stub!(:permissions).and_return('view' => %w{manager}) # managers can see anything, always, it's hardcoded
      end
  
      it "user (public) viewers" do
        user = Factory.create :user
  
        o = AModel.new
        o.stub!(:viewers){%w{user}}
  
        user.can?(:view, o).should be_true
      end
  
      it "member viewers" do
        Space.stub!(:permissions).and_return('view' => [])
  
        user = Factory.create :user
        member = Factory.create :member
        manager = Factory.create :manager
        
        o = AModel.new
        o.stub!(:viewers).and_return(%w{member manager})
  
        user.can?(:view, o).should be_false
        member.can?(:view, o).should be_true
        manager.can?(:view, o).should be_true
      end
  
      it "owner (private) viewers" do
        Space.stub!(:permissions).and_return('view' => [])
  
        owner = Factory.create :user, :name => "aname"
        user = Factory.create :user
        member = Factory.create :member
        manager = Factory.create :manager
  
        o = AModel.new
        o.stub!(:owner_name){owner.name}
        o.stub!(:viewers){%w{user:aname manager}}
  
        owner.can?(:view, o).should be_true
        user.can?(:view, o).should be_false
        member.can?(:view, o).should be_false
        manager.can?(:view, o).should be_true
      end
  
      it "should correct works with non authorized objects (from error)" do
        user = Factory.create :user    
        user.can?(:view, Object.new).should be_false
      end
    end
    
  end
end