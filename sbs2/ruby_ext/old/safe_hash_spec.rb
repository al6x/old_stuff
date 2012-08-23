require 'spec_helper'

describe "SafeHash and SafeNil" do
  it "should allow check for value presence" do
    h = SafeHash.new a: :b
    h.a?.should be_true
    h.b?.should be_false

    h.should include(:a)
    h.should_not include(:b)
  end

  it "? should return boolean (from error)" do
    h = SafeHash.new
    lambda{raise "" unless h.a?.class.equal?(NilClass)}.should raise_error
    lambda{raise "" unless h.a.a?.class.equal?(NilClass)}.should raise_error
  end

  it "passing block should be threated as invalid usage" do
    h = SafeHash.new
    lambda{h.development{}}.should raise_error(/invalid usage/)
  end

  it "should treat assigned nil as value (from error)" do
    h = SafeHash.new v: nil
    h.v?.should be_true
    h.v!.should == nil
  end

  it "should modify hash" do
    h = SafeHash.new
    h.a = 1
    h.a!.should == 1
    h[:b] = 1
    h.b!.should == 1
    lambda{h.c.d = 1}.should raise_error(/no key/)
  end

  # it "should allow owerride values" do
  #   h = SafeHash.new a: :b
  #   h.b = :c
  #   h.b!.should == :c
  # end

  it "general behaviour" do
    h = SafeHash.new key: :value

    h.key.should == :value
    h.key(:missing).should == :value

    h[:key].should == :value
    h[:key, :missing].should == :value

    h['key'].should == :value
    h['key', :missing].should == :value

    h.a.b.c[:d].e('missing').should == 'missing'
    h.a.b.c[:d][:e, 'missing'].should == 'missing'
  end

  it "should build hierarchies of SafeHash" do
    h = SafeHash.new a: {a: :b}

    h.a.a.should == :b
    h.a.missing.b.c('missing').should == 'missing'
  end

  it "should require setting if ! used" do
    h = SafeHash.new a: :v, b: {c: :v}

    h.a!.should == :v
    h.b.c!.should == :v
    h.b!.c!.should == :v

    lambda{h.j!}.should raise_error(/no key :j/)
    lambda{h.j.b.c!}.should raise_error(/no key :c/)
  end

  # it "should be able to update itself" do
  #   h = SafeHash.new
  #   h.b?.should be_false
  #   h.merge! a: :a
  #   h.a!.should == :a
  # end

  it "should implement include?" do
    h = SafeHash.new a: :b
    h.include?(:a).should be_true
    h.include?('a').should be_true
    h.include?(:b).should be_false

    h.b.include?(:a).should be_false
  end

  # it "merge_if_blank" do
  #   h = SafeHash.new a: :b
  #   h.merge_if_blank! a: :c, d: :e
  #   h.a!.should == :b
  #   h.d!.should == :e
  # end
end