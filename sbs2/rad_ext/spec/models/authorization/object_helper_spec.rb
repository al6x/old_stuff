require 'spec_helper'

describe "Authorization, ObjectHelper" do
  with_models

  user_class = nil
  before do
    user_class = Models::UserStub
    class AModel
      inherit Mongo::Model
      inherit Models::Authorization::ObjectHelper

      collection :a_models
    end
  end

  after{remove_constants :AModel}

  describe "Owner, Viewers, Collaborators" do
    before do
      rad.delete :user
      @user = user_class.new.set name: 'auser', roles: %w(user:auser)
    end

    it "should be able to create objects (from error)" do
      rad.user = @user
      o = AModel.new
      o.save!
    end

    it "should by default set current user_name as owner_name if there is current user" do
      o = AModel.new
      o.owner_name.should be_nil

      rad.user = @user
      o = AModel.new
      o.owner_name.should == 'auser'
    end

    it "owner" do
      o = AModel.new
      o.owner = @user
      o.owner_name.should == @user.name
      o.viewers.should == %w(admin manager user:auser)
      o.should be_valid
    end

    it 'viewers' do
      o = AModel.new
      o.owner = @user
      o.viewers.add :user
      o.viewers.should == %w(admin manager member user user:auser)
      o.should be_valid

      o.viewers.delete :user
      o.viewers.should == %w(admin manager member user:auser)
      o.should be_valid

      o.viewers.add :user
      o.viewers.should == %w(admin manager member user user:auser)
      o.should be_valid
    end

    it "duplicate roles (from error)" do
      o = AModel.new
      o.owner = @user
      o.save!

      # Don't use reload, it willn't catch this error.
      o = AModel.first
      o.viewers.should == %w(admin manager user:auser)
    end

    it "collaborators" do
      o = AModel.new
      o.owner = @user
      o.collaborators.add :member
      o.collaborators.should == %w(member)
      o.should be_valid

      o.collaborators.delete :member
      o.collaborators.should == %w()
      o.should be_valid
    end

    it "normalized_collaborators" do
      o = AModel.new
      o.owner = @user
      o.collaborators.add :member
      o.collaborators.with_all_higher_roles.should == %w(admin manager member user:auser)
    end

    it "anonymous should never be collaborator (from error)" do
      @user = user_class.new.set name: 'anonymous'
      o = AModel.new
      o.owner = @user
      o.collaborators.with_all_higher_roles.should == []
    end

    it "viewers and collaborators dependance" do
      o = AModel.new
      o.owner = @user
      o.collaborators.add :user
      o.collaborators.should == %w(user)
      o.viewers.should == %w(admin manager member user user:auser)
      o.should be_valid

      o.viewers.delete :member
      o.viewers.should == %w(admin manager user:auser)
      o.collaborators.should == %w()
    end

    it "minor viewers" do
      o = AModel.new
      o.owner = @user
      o.viewers.add :member
      o.viewers.should == %w(admin manager member user:auser)
      o.viewers.minor.should == %w(member user:auser)
    end

    it "collaborators should be able to update object" do
      col = Models::UserStub.new.set name: 'collaborator', roles: %w(member)

      o = AModel.new
      o.owner = @user
      col.can?(:update, o).should be_false
      @user.can?(:update, o).should be_true

      o.collaborators.add :member
      o._cache.clear
      col.can?(:update, o).should be_true
      @user.can?(:update, o).should be_true
    end
  end

  describe "Permissions" do
    describe "General" do
      it "should works for new user" do
        u = factory.build :user
        u.can?(:manage, AModel)
      end

      it 'permissions' do
        u = factory.build :user
        u.can?(:manage, AModel).should be_false

        u = factory.build :manager, permissions: {'manage' => true}
        u.can?(:manage, AModel).should be_true
      end
    end

    describe "as Owner" do
      before do
        @user = factory.build :user, owner_permissions: {'manage' => true}

        @object = AModel.new
        @owned_object = AModel.new
        @owned_object.owner = @user
      end

      it "owner?" do
        @user.should_not be_owner(@object)
        @user.should be_owner(@owned_object)
      end

      it "anonymous should never be owner of anything" do
        @user = factory.build :anonymous

        @owned_object = AModel.new
        @owned_object.owner = @user

        @user.should_not be_owner(@owned_object)
      end

      it 'permissions for owner' do
        @user.can?(:manage, @object).should be_false
        @user.can?(:manage, @owned_object).should be_true
      end
    end

    describe "Special :view permission" do
      # before do
      #   # Managers can see anything, always.
      #   # user_helper.custom_permissions = {'view' => %w(manager)}
      # end

      it "user (public) viewers" do
        user = factory.build :user

        o = AModel.new
        o.stub!(:viewers){%w(user)}

        user.can?(:view, o).should be_true
      end

      it "member viewers" do
        user = factory.build :user
        member = factory.build :member
        manager = factory.build :manager

        o = AModel.new
        o.stub!(:viewers).and_return(%w(member manager))

        user.can?(:view, o).should be_false
        member.can?(:view, o).should be_true
        manager.can?(:view, o).should be_true
      end

      it "owner (private) viewers" do
        owner   = factory.build :user, name: "aname"
        user    = factory.build :user
        member  = factory.build :member
        manager = factory.build :manager

        o = AModel.new
        o.stub!(:owner_name){owner.name}
        o.stub!(:viewers){%w(user:aname manager)}

        owner.can?(:view, o).should be_true
        user.can?(:view, o).should be_false
        member.can?(:view, o).should be_false
        manager.can?(:view, o).should be_true
      end

      it "should correct works with non authorized objects (from error)" do
        user = factory.build :user
        user.can?(:view, Object.new).should be_false
      end
    end

  end
end