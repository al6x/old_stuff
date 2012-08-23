require 'spec_helper'

describe 'Config' do
  old_mode = nil
  before do
    old_mode = rad.mode
    rad.mode = :development, true
    @c = Rad::Config.new key: 'value', key2: 'value2'
  end
  after{rad.mode = old_mode, true}

  it "clone" do
    c = Rad::Config.new a: {b: :c}

    c2 = c.clone
    c.a.delete :b
    c.delete :a

    c2.a[:b].should == :c
  end
end