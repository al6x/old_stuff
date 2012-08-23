require 'spec_helper'

require 'rad'
require 'rad/spec/environment'

describe 'Config' do
  before do
    rad.mode = :development, true
    @c = Rad::Config.new key: 'value', key2: 'value2'
  end
  after{rad.mode = :test, true}

  it "should merge with existing config" do
    @c.key2.should == 'value2'
    @c.merge_config! "#{spec_dir}/config.yml"
    @c.key.should == 'value'
    @c.key2.should == 'another_value'
  end

  it "should merge hashes (with the following order: config.default <= config <= rad.mode)" do
    @c.merge_config! "#{spec_dir}/config.yml"

    @c.users[:default_key].should == 'default_value'
    @c.users[:key].should == 'value'
    @c.users[:test_key].should == 'test_value'
    @c.users[:name].should == 'test_name'
  end

  describe "Merger" do
    it "should override by default" do
      h = Rad::Config.new a: :b
      Rad::Config::Merger.new(h).merge! a: :c
      h.a.should == :c
    end

    it "should skip existing if specified" do
      h = Rad::Config.new a: :b
      Rad::Config::Merger.new(h, override: false, blank: true).merge!(a: :c, d: :e)
      h.a.should == :b
      h.d.should == :e
    end

    it "merging hashes should not be countig as overriding" do
      h = Rad::Config.new b: {c: :d}
      Rad::Config::Merger.new(h, override: false).merge! b: {e: :f}
      h.b[:c].should == :d
      h.b[:e].should == :f
    end

    it "should not override if specified" do
      h = Rad::Config.new a: {b: :c}
      lambda{Rad::Config::Merger.new(h, override: false).merge!(a: {b: :c2})}.should raise_error(/can't override.*b/)
    end

    it "should perform deep merge by default" do
      h = Rad::Config.new a: {b: {c: :d}}
      Rad::Config::Merger.new(h).merge!({a: {b: {c2: :d2}}})
      h.a[:b][:c].should == :d
      h.a[:b][:c2].should == :d2
    end
  end
end