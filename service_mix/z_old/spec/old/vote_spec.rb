# require File.dirname(__FILE__) + '/../spec_helper'
# 
# describe Vote do
#   before :each do
#     # set_account Factory.build(:account)
#     set_space Factory.build(:space)
#   end
#   
#   it "move to Bin and restore" do
#     v = Factory.create :vote
#     r = v.resource
#     r.rating = 1
#     
#     v.move_to_bin
#     r.rating.should == 0
#     
#     v.restore_from_bin
#     r.rating.should == 1
#   end
# end