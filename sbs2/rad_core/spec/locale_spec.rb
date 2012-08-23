# encoding: utf-8

require 'spec_helper'

describe 'locale' do
  inject :locale

  before_all do
    locale.paths += Dir["#{spec_dir}/locales/*"]
  end

  it "basic" do
    locale.current = 'en'
    locale.t(:name).should == "Name"
    locale.t(:name).is_a?(String).should be_true

    locale.current = 'ru'
    locale.t(:name).should == "Имя"
  end

  it "pluggable pluralization" do
    locale.current = 'ru'
    locale.t(:comments_count, count: 1).should == "1 комментарий"
    locale.t(:comments_count, count: 2).should == "2 комментария"
    locale.t(:comments_count, count: 5).should == "5 комментариев"
  end
end