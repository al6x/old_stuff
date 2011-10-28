require 'rspec_ext'
require "fake_gem"

describe FakeGem do
  old_environment = nil
  before do
    old_environment = [$LOAD_PATH.clone, ENV['FAKE_GEM_PATHS']]

    ENV['FAKE_GEM_PATHS'] = nil
    FakeGem.clear
  end

  after do
    $LOAD_PATH.replace old_environment.first
    ENV['FAKE_GEM_PATHS'] = old_environment.last
  end

  it "should use FAKE_GEM_PATHS environment variable or paths assigned to FakeGem::paths attribute" do
    FakeGem.paths.should == []

    FakeGem.clear
    ENV['FAKE_GEM_PATHS'] = "/first_path:/second_path"
    FakeGem.paths.should == %w(/first_path /second_path)

    FakeGem.paths '.'
    FakeGem.paths.should == [File.expand_path('.')]

    FakeGem.clear
    FakeGem.paths = ['.']
    FakeGem.paths.should == [File.expand_path('.')]
  end

  it "should require directories with fake_gem as gems" do
    FakeGem.paths "#{spec_dir}/common"
    FakeGem.gems.size.should == 1

    require 'project_a_file'
    -> {require 'project_b_file'}.should raise_error(/no such file to load/)

    $LOAD_PATH.should include("#{spec_dir}/common/project_a/lib")
    $LOAD_PATH.should_not include("#{spec_dir}/common/project_b/lib")
  end

  it "hould load directories with fake_gem as gems" do
    FakeGem.paths "#{spec_dir}/common"
    FakeGem.gems.size.should == 1

    gem 'project_a'

    $LOAD_PATH.should include("#{spec_dir}/common/project_a/lib")
  end

  it "should load directories with fake_gem as gems" do
    FakeGem.paths "#{spec_dir}/common"
    FakeGem.gems.size.should == 1

    load 'project_a_file.rb'
    -> {load 'project_b_file.rb'}.should raise_error(/no such file to load/)

    $LOAD_PATH.should include("#{spec_dir}/common/project_a/lib")
    $LOAD_PATH.should_not include("#{spec_dir}/common/project_b/lib")
  end

  it "should not require twice" do
    FakeGem.paths "#{spec_dir}/twice"

    # rspec usually adds this dirs, and its mandatory for our spec to add thouse dirs to $LOAD_PATH
    $LOAD_PATH << "#{spec_dir}/twice/kit/lib"
    $LOAD_PATH << "#{spec_dir}/twice/kit/spec"

    -> {require 'spec_helper'}.should raise_error(LoadError, /non_existing_file/)
  end
end