require 'spec_helper'

describe "Analytics" do
  with_controllers
  set_controller Controllers::Analytics
  login_as :global_admin

  it "should display list of domains" do
    domain = Factory.create :domain, views: {Time.now.year.to_s => {'1' => 16}}
    call :all
    response.should be_ok
    response.body.should include('16')
  end
end