require 'spec_helper'

describe "Item" do
  with_models
  login_as :user

  it 'should validate slug' do
    i = factory.create :item
    i.slug = 'space '
    i.should_not be_valid
  end
end