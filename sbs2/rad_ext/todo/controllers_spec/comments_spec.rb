require 'spec_helper'

describe "Comments" do
  with_controllers
  set_controller Controllers::Comments
  login_as :user

  before do
    @item = factory.create :item
  end

  def create_comment original_text = 'text'
    factory.create :comment, item: @item, owner: @user
  end

  it "should display new dialog" do
    call :new, format: 'js', item_id: @item.to_param
    response.should be_ok
  end

  it "should create Comment" do
    comment_attributes = factory.attributes_for :comment
    pcall :create, format: 'js', item_id: @item.to_param, model: comment_attributes
    response.should be_ok

    Models::Comment.count(_class: 'Models::Comment').should == 1
    comment = Models::Comment.first(_class: 'Models::Comment')

    comment.original_text.should == comment_attributes[:original_text]

    comment.owner.name.should == @user.name
    comment.item.name.should == @item.name
  end

  it "should display edit dialog" do
    comment = create_comment
    call :edit, format: 'js', id: comment.to_param
    response.should be_ok
  end

  it "should update Comment" do
    comment = create_comment
    new_attributes = {original_text: 'new text'}
    pcall :update, format: 'js', id: comment.to_param, model: new_attributes
    response.should be_ok

    comment.reload
    comment.original_text.should == 'new text'
  end

  it "should delete Comment" do
    comment = create_comment
    pcall :delete, format: 'js', id: comment.to_param
    Models::Comment.count(_class: 'Models::Comment').should == 0
  end
end