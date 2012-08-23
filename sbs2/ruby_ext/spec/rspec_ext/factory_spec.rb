require 'spec_helper'

describe "Factory" do
  before do
    factory.registry.clear
    factory.counters.clear
  end
  after{remove_constants :User, :ATmp, :BTmp}

  it "should build objects from definition" do
    factory.define :user, class: 'OpenObject' do |u|
      u.name = 'an_user'
    end

    factory.build(:user, password: 'abc'){|u| u.roles = %w(user)}.should ==
      {name: 'an_user', password: 'abc', roles: %w(user)}.to_openobject
  end

  it "should provide parent to represent hierarchies" do
    factory.define :user, class: 'OpenObject' do |u|
      u.name = 'an_user'
    end

    factory.define :manager, parent: :user do |u|
      u.name = 'a_manager'
    end

    factory.build(:manager, password: 'abc'){|u| u.roles = %w(manager)}.should ==
      {name: 'a_manager', password: 'abc', roles: %w(manager)}.to_openobject
  end

  it "should create create objects" do
    stub = self.stub
    factory.define :user, class: stub
    factory.define :manager, parent: :user

    stub.should_receive(:new).once.and_return stub
    stub.should_receive(:save!).once
    factory.create :manager
  end

  it "should validate input" do
    -> {factory.define :user}.should raise_error(/provided for :user/)
  end

  it "should provide counters" do
    factory.next(:id).should == 0
    factory.next(:id).should == 1
  end

  it "should use correct creation method (build / create) in associations" do
    class ATmp
      attr_accessor :b
      def save!; end
    end

    class BTmp
      attr_accessor :saved
      def save!
        @saved = true
      end
    end

    factory.define :a, class: 'ATmp' do |o|
      # b will be either build or create, method will be choosen automatically.
      o.b = factory :b
    end
    factory.define :b, class: 'BTmp'

    factory.build(:a).b.saved.should be_nil
    factory.create(:a).b.saved.should be_true
  end
end