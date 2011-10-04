require 'spec_helper'

describe "Container" do
  with_models
  
  before :all do
    class ::AList < Item
      plugin MongoMapper::Plugins::AuthorizedObject
      acts_as_authorized_object
      
      contains :elements
      add_order_support_for :elements
    end
    
    class ::ATask < Item      
      plugin MongoMapper::Plugins::AuthorizedObject
      acts_as_authorized_object
    end
  end
  
  before do
    login_as Factory.create(:user, name: 'auser')
  end
  
  after :all do
    [:AList, :ATask].each{|c| Object.send :remove_const, c if Object.const_defined? c}
  end  
  
  def create_container_with_item! dependent = true
    @t = ATask.create! dependent: dependent
    @l = AList.new
    @l.elements << @t
    @l.save!
    @l.reload; @t.reload
  end
  
  it "should add items" do
    create_container_with_item!
  
    @l.elements.should == [@t]
    @l.element_ids.should == [@t.id]
    @l.item_ids.should == [@t.id]
    
    @t.containers.should == [@l]
  end
  
  it "dependent items should be destroyed with container" do
    create_container_with_item!
    @l.destroy
    AList.count.should == 0
    ATask.count.should == 0
  end
  
  it "independent items should not be destroyed with container" do 
    create_container_with_item! false
    @l.destroy
    AList.count.should == 0
    ATask.count.should == 1    
  end
  
  it "independent_container" do
    create_container_with_item!
    @t.independent_container.should == @l
  end
  
  it "item should remove self from conainers if destroyed" do
    create_container_with_item!
    @t.destroy
    @l.reload
      
    @l.element_ids.should be_empty
    @l.elements.should be_empty
    @l.ordered_elements.should be_empty
    @l.item_ids.should be_empty
  end
  
  it "container should support order" do
    create_container_with_item!
    @t2 = ATask.create!
    @l.elements << @t2
    @l.save!
    
    @l.ordered_elements.should == [@t, @t2]
    
    @l.update_element_order @t2, 0
    @l.save!
    @l.reload
    @l.ordered_elements.should == [@t2, @t]
  end
  
  it "dependent task should inherit collaborators from it's list (from error)" do
    create_container_with_item!
    @l.add_collaborator :member
    @l.save!
    
    @t.reload
    @t.collaborators.should include('member')
  end
  
  it "inheritable container attributes should be propagated to contained items" do
    @t = ATask.new
    @t.add_viewer :user
    @t.viewers.should == %w{manager member user user:auser}
    @t.should be_valid
  
    @t.dependent!
    @t.viewers.should == %w{manager member user user:auser}
    @t.should be_valid
  end
  
  it "inheritable container attributes should be propagated to contained items (recursivelly)" do
    l1 = AList.create
    
    l2 = AList.create dependent: true
    l1.elements << l2
    l1.save!
    
    t = ATask.create dependent: true
    l2.elements << t
    l2.save!
    
    l1.add_viewer :member
    l1.save!
    
    l1.reload; l2.reload; t.reload
    
    l1.viewers.should == %w{manager member user:auser}
    l2.viewers.should == %w{manager member user:auser}
    t.viewers.should == %w{manager member user:auser}
  end
  
  it "if item created as dependent it should copy inheritable attributes from container" do
    l = AList.new
    l.add_viewer :director
    t = ATask.new dependent: true
    t.inherit_container_attributes l
    t.viewers.should == %w{director manager user:auser}
  end
end