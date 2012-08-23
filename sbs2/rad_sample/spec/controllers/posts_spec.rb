require 'spec_helper'

describe "Posts" do  
  with_controllers
  set_controller Controllers::Posts
  Post = Models::Post
  
  it "show" do
    post = Factory.create :post
    call :show, id: post.to_param
    response.should be_ok
    response.body.should include(post.name)
  end
  
  it "all" do
    post = Factory.create :post
    call :all
    response.should be_ok
    response.body.should include(post.name)
  end
  
  it "edit" do
    post = Factory.create :post
    call :edit, id: post.to_param, format: 'js'
    response.should be_ok
  end
  
  it "new" do    
    call :new, format: 'js'
    response.should be_ok
  end
  
  it "create" do
    attrs = Factory.attributes_for :post
    pcall :create, model: attrs, format: 'js'

    response.body.should include('window.location')
    Post.count.should == 1
    post = Post.first
    post.name.should == attrs[:name]
  end
  
  it "update" do
    post = Factory.create :post
    pcall :update, id: post.to_param, model: {name: 'new_name'}, format: 'js'

    response.should be_ok
    response.body.should =~ /new_name/

    post.reload
    post.name.should == 'new_name'
  end

  it "destroy" do
    post = Factory.create :post
    pcall :destroy, id: post.to_param, format: 'js'
    response.should be_ok
    Post.count.should == 0
  end
end