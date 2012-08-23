require "spec_helper"

describe "Help" do
  set_controller Rad::Face::Demo::Helps
  
  it "should display general help page" do
    wcall :index
    response.should be_ok
  end
  
  it "should display theme help" do
    wcall :help, theme: 'default'
  end
end