require 'mongoid_misc/spec_helper'

describe "BelongsToWithCounterCache" do
  with_mongoid
  
  before :all do
    class ::Post
      include Mongoid::Document      
      
      field :comments_count, type: Integer, default: 0
      has_many :comments
    end
    
    class ::Comment
      include Mongoid::Document
      
      field :post_id
      belongs_to :post, counter_cache: true
    end
  end  
  after(:all){remove_constants :Post, :Comment}
  
  it "should increase count of comments" do
    post = Post.create!
    comment = post.comments.create!
    
    post.reload
    post.comments_count.should == 1
  end
  
  it "should decrease count of comments" do
    post = Post.create!
    comment = post.comments.create!
    post.reload
    post.comments_count.should == 1
    
    comment.destroy    
    post.reload
    post.comments_count.should == 0
  end  
end