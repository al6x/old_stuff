require 'spec_helper'

describe 'Assets' do
  the_spec_dir = with_tmp_spec_dir

  with_load_path \
    "#{the_spec_dir}/app/lib",
    "#{the_spec_dir}/plugin_a/lib",
    "#{the_spec_dir}/plugin_b/lib"

  before do
    rad.stub!(:runtime_path).and_return "#{spec_dir}/app/runtime"
    load "app/init.rb"
  end

  it "should copy assets" do
    rad.assets.copy_to_public!
    "#{spec_dir}/app/runtime/public/assets/my_app.js".to_file.should exist
    "#{spec_dir}/app/runtime/public/assets/lib/my_vendor.js".to_file.should exist
  end
end