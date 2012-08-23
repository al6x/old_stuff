require 'spec_helper'

describe "Post" do
  with_models
  
  it "smoke test" do
    comment = Factory.create :post
    post = Models::Post.first
    post.text.should == 'some text'
  end
end