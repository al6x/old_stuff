require 'spec_helper'

describe "Items" do
  with_controllers
  login_as :manager, name: 'auser'

  describe "Basic" do
    set_controller Controllers::Items

    it "should update layout" do
      @item = factory.create :item
      @item.layout.should == nil

      pcall :layout, id: @item.to_param, value: 'home', format: 'js'
      response.should be_ok

      @item.reload
      @item.layout.should == 'home'
    end

    it 'viewers, add_roles' do
      @item = factory.create :item
      @item.viewers.should == %w(manager user:auser)
      @item.owner_name.should == @user.name

      pcall :viewers, id: @item.to_param, add_roles: 'user', format: 'js'
      response.should be_ok

      @item.reload
      @item.viewers.should == %w(manager member user user:auser)
    end

    it "should redirect to /items if no default_url specified" do
      call :redirect
      response.should redirect_to(rad.router.default_url)
    end

    it "should display :all" do
      call :all
      response.should be_ok
    end

  end
end