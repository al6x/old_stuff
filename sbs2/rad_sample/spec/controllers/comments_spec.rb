require 'spec_helper'

describe "Comments" do  
  with_controllers
  set_controller Controllers::Comments
  Comment = Models::Comment
  
  before{@post = Factory.create :post}
  
  it "edit" do
    comment = Factory.create :comment, node: @post
    call :edit, id: comment.to_param, format: 'js'
    response.should be_ok
  end
  
  it "new" do    
    call :new, format: 'js'
    response.should be_ok
  end
  
  it "create" do
    attrs = Factory.attributes_for :comment
    pcall :create, model: attrs, node_id: @post.id.to_s, format: 'js'
    
    response.body.should include(attrs[:text])
    Comment.count.should == 1
    comment = Comment.first
    comment.text.should == attrs[:text]
  end
  
  it "update" do
    comment = Factory.create :comment, node: @post
    pcall :update, id: comment.to_param, model: {text: 'new_text'}, format: 'js'

    response.should be_ok
    response.body.should =~ /new_text/

    comment.reload
    comment.text.should == 'new_text'
  end

  it "destroy" do
    comment = Factory.create :comment, node: @post
    pcall :destroy, id: comment.to_param, format: 'js'
    response.should be_ok
    Comment.count.should == 0
  end
end