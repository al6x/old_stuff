require 'spec_helper'

describe "Environment basic spec" do
  the_spec_dir = with_tmp_spec_dir

  with_load_path \
    "#{the_spec_dir}/plugin_a/lib",
    "#{the_spec_dir}/plugin_b/lib",
    "#{the_spec_dir}/app/lib"

  before do
    Tmp = []
    rad.runtime_path = the_spec_dir, true

    load "app/init.rb"
  end
  after do
    rad.delete_all :custom_component
    remove_constants :Tmp
  end

  it "core components" do
    rad.logger.should_not be_nil
    rad.environment.should_not be_nil
    rad.config.should_not be_nil
  end

  it "loading order" do
    rad.environment
    rad.register(:custom_component){true}
    rad.custom_component
    Tmp.should == %w(init plugin_a)
  end
end