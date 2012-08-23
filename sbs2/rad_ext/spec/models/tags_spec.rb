require 'spec_helper'

describe "Tags" do
  with_models
  login_as :user

  it "should support context" do
    tags = Models::Tags.new ['a', 'b', 'viewers:alex']
    tags.as_string.should == 'a, b, viewers:alex'

    tags.topic.should == ['a', 'b']
    tags.topic.as_string.should == 'a, b'

    tags.viewers.should == ['viewers:alex']
    tags.viewers.as_string.should == 'viewers:alex'

    tags.topic = 'c, d, other:a'
    tags.should == ['c', 'd', 'viewers:alex']

    tags.viewers = 'viewers:john, a'
    tags.should == ['c', 'd', 'viewers:john']
  end

  it "should create tags when object created (from error)" do
    item = Models::Item.new name: 'item'
    item.tags = ['a', 'b']

    item.save!

    item.reload

    item.tags.topic.should == ['a', 'b']
    all_tags = Models::Tag.all.collect(&:name)
    all_tags.should include('a')
    all_tags.should include('b')
  end

  it "should create tags" do
    item = factory.create :item, topics_as_string: 'a, b'
    Models::Item.count.should == 1
    item.reload
    item.tags.topic.should == ['a', 'b']

    all_tags = Models::Tag.all.collect(&:name)
    all_tags.should include('a')
    all_tags.should include('b')
  end

  it "should update tags after item update" do
    item = factory.create :item, topics_as_string: 'a, b'
    all_tags = Models::Tag.all.collect(&:name)
    all_tags.should include('a')
    all_tags.should include('b')

    item.tags = ['a', 'c']
    item.save!

    all_tags = Models::Tag.all.collect(&:name)
    all_tags.should include('a')
    all_tags.should_not include('b')
    all_tags.should include('c')
  end

  it "should update tags after item deletion" do
    item = factory.create :item, topics_as_string: 'a, b'
    Models::Tag.count.should == 3

    item = item.class.by_id item._id
    item.delete
    Models::Tag.count.should == 0
  end
end