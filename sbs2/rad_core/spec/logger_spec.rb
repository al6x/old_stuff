require 'spec_helper'

describe "Environment basic spec" do
  it "logger should work before Rad initialized" do
    rad.logger.should_not be_nil
  end
end