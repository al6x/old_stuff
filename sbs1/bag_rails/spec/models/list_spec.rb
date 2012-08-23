require 'spec_helper'

describe "List" do  
  with_models
  
  before do 
    @user = Factory.create :user
    login_as @user
    
    @list = Factory.create :list
  end
  
  it "should move finished task to bottom" do
    3.times{@list.items << Factory.create(:task)}
    @list.save!
    
    task = @list.items.first
    task.finish
    task.save!
    
    @list.reload
    @list.ordered_items.index(task).should == 2
  end
end