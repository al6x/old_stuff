require 'spec_helper'

describe "Notes" do
  with_controllers
  set_controller Controllers::Products
  login_as :manager

  it_should_behave_like "Items Controller CRUD"

  it "buy :js" do
    product = Factory.create :product
    pcall :buy, id: product.to_param, format: 'js'
    response.should be_ok
  end

  it "checkout :js" do
    rad.store.stub!(:order_processing_email).and_return('store_owner@mail.com')
    rad.users.stub!(:email).and_return("my_store.com")

    product = Factory.create :product
    order = Factory.attributes_for :order
    pcall :checkout, id: product.to_param, order: order, format: 'js'
    sent_letters.size.should == 1
    response.should be_ok
  end
end