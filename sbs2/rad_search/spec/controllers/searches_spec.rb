require 'controllers/spec_helper'

describe 'search' do
  with_bag_controller{Bag::Searches}
  login_as :manager

  # before do    
  #   set_default_space
  # 
  #   @user = Factory.create :manager
  #   login_as @user
  # end  
  
  it "resolve_container" do
    l = Factory.create :list
    t = Factory.create :task, dependent: true
    l.items << t
    l.save!
    
    call :resolve_container, id: t.to_param
    response.should be_redirect
    response.body.should include(l.to_param)
  end
end