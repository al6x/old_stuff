require 'spec_helper'

describe "Account" do
  with_models

  # Rejected
  # it "should delete all dependent items and spaces" do
  #   class Plane
  #     inherit Mongo::Model
  #     belongs_to_space
  #   end
  #
  #   plane = Plane.create!
  #
  #   rad.account.destroy
  #   rad.space.exist?.should be_false
  #   plane.exist?.should be_false
  # end
  # after{remove_constants :Plane}
end