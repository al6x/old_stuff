require "spec_helper"

describe 'OpenObject' do
  it 'should be comparable with hashes' do
    {}.to_openobject.should == {}
    {}.should == {}.to_openobject

    {a: :b}.to_openobject.should == {a: :b}
    {'a' => :b}.to_openobject.should == {a: :b}

    {a: :b}.to_openobject.should == {'a' => :b}
    {'a' => :b}.to_openobject.should == {'a' => :b}

    {a: :b}.to_openobject.should_not == {a: :c}
  end

  it "must be hash (from error)" do
    {}.to_openobject.is_a?(Hash).should be_true
  end

  it 'merge! should be indifferent to string and symbol' do
    oo = OpenObject.new
    oo.merge! a: true
    oo.a.should be_true
    oo.merge! 'b' => true
    oo.b.should be_true
  end
end