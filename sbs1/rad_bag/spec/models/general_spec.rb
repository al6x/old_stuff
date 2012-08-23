require 'spec_helper'

describe "Miscellaneous" do
  with_models
  login_as :manager

  it "items should be polymorphic" do
    Factory.create :note
    Models::Item.first.should be_a(Models::Note)
  end
end