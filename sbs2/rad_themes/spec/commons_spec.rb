require "spec_helper"

describe "Commons" do
  before{@theme = 'simple_organization'}

  it_should_behave_like "commons demo"
end