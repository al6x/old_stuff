require 'mongoid_misc/spec_helper'

describe "Simple Finders" do
  with_mongoid
  
  before :all do
    class User
      include Mongoid::Document

      field :name, default: String
    end
  end
  after(:all){remove_constants :User}    
    
  it "find, first, by" do
    User.find_by_name('John').should be_nil    
    -> {User.find_by_name!('John')}.should raise_error(Mongoid::Errors::DocumentNotFound)
    User.by_name('John').should be_nil    
    -> {User.by_name!('John')}.should raise_error(Mongoid::Errors::DocumentNotFound)
    User.first_by_name('John').should be_nil    
    -> {User.first_by_name!('John')}.should raise_error(Mongoid::Errors::DocumentNotFound)
    
    john = User.create! name: 'John'
    
    User.find_by_name('John').should == john
    User.find_by_name!('John').should == john
    User.by_name('John').should == john
    User.by_name!('John').should == john
    User.first_by_name('John').should == john
    User.first_by_name!('John').should == john
  end
  
  it "all" do
    User.all_by_name('John').should == []    
    john = User.create! name: 'John'    
    User.all_by_name('John').should == [john]
  end
  
  it "should allow to use bang version only with :first" do
    -> {User.all_by_name!('John')}.should raise_error(/can't use bang/)
  end
  
  it "by_id (special case)" do
    User.method(:by_id).should == User.method(:find_by_id)
    User.method(:by_id!).should == User.method(:find_by_id!)
    
    User.by_id('4de81858cf26bde569000009').should be_nil    
    -> {User.by_id!('4de81858cf26bde569000009')}.should raise_error(Mongoid::Errors::DocumentNotFound)
    
    john = User.create! name: 'John'
    
    User.by_id(john.id).should == john
    User.by_id(john.id.to_s).should == john
    User.by_id!(john.id).should == john
  end
end