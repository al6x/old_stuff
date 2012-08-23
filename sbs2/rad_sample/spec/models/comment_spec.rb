require 'spec_helper'

describe "Comment" do
  with_models
  
  it "smoke test" do
    comment = Factory.create :comment
    Models::Comment.first.text.should == 'some text'
  end
end