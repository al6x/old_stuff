require 'spec_helper'

describe "Minimal App" do
  before_all{load "#{spec_dir}/app.rb"}

  it "core components" do
    rad.logger.should_not be_nil
    rad.environment.should_not be_nil
    rad.config.should_not be_nil
  end
end