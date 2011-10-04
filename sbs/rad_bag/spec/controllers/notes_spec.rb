require 'spec_helper'

describe "Notes" do
  with_controllers
  set_controller Controllers::Notes
  login_as :manager

  it_should_behave_like "Items Controller CRUD"
end