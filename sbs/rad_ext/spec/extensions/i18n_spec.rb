# encoding: utf-8

require "spec_helper_with_rad"

describe 'I18n' do
  before :all do
    rad.web
    rad.reset :conveyors
    
    I18n.load_path += Dir["#{spec_dir}/locales/*/*.{rb,yml}"]
  end
  
  def t *args
    I18n.t *args
  end
  
  it "basic" do
    I18n.locale = 'en'
    t(:name).should == "Name"
    t(:name).is_a?(String).should be_true
    
    I18n.locale = 'ru'
    t(:name).should == "Имя"
  end
  
  it "pluggable pluralization" do
    I18n.locale = 'ru'
    t(:comments_count, count: 1).should == "1 комментарий"
    t(:comments_count, count: 2).should == "2 комментария"
    t(:comments_count, count: 5).should == "5 комментариев"
  end
end