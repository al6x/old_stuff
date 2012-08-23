require 'spec_helper'

describe "TextProcessor" do
  with_mongo_model
  after(:all){remove_constants :Post}

  it "should provide markup helpers for model" do
    class Post
      inherit Mongo::Model
      collection :posts

      attr_accessor :text
      available_as_markup :text

      validates_presence_of :text
    end

    post = Post.new
    post.valid?.should be_false
    post.errors[:original_text].should be_present

    post = Post.new
    post.original_text = "<h1>Hello</h1>"
    post.text.should  == "<h1>Hello</h1>"
    post.save.should be_true
  end
end