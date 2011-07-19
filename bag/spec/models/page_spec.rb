require 'spec_helper'

describe "Page" do  
  with_models
  
  before do
    @user = Factory.create :user, name: 'auser'
    login_as @user
  end
  
  it "should support ordered Items" do
    page = Factory.build :page
    
    item1 = Factory.build :item, name: 'first'
    page.items << item1
    
    item2 = Factory.build :item, name: 'second'
    page.items << item2
        
    page.ordered_items.should == [item1, item2]
    page.save!
    page.reload
    page.ordered_items.should == [item1, item2]
  end
  
  it 'should add item' do
    page = Factory.build :page
    
    item1 = Factory.build :item, name: 'first'
    page.items << item1
    
    item2 = Factory.build :item, name: 'second'
    page.items << item2
        
    page.update_item_order item2, 0
    page.clear_cache
    page.ordered_items.should == [item2, item1]
  end
  
  it 'update_item_order' do
    page = Factory.build :page
    
    item1 = Factory.build :item, name: 'first'
    page.items << item1
    
    item2 = Factory.build :item, name: 'second'
    page.items << item2
        
    page.item_ids.should == [item1.id, item2.id]
    
    page.update_item_order item2, 0
    page.item_ids.should == [item2.id, item1.id]
    page.save!
    
    page.reload
    page.ordered_items.should == [item2, item1]
  end
end