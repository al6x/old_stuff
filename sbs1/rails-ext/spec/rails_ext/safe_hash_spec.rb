require 'spec'

require 'active_support'
require "#{File.dirname __FILE__}/../../lib/rails_ext/micelaneous/safe_hash"

describe "SafeHash and SafeNil" do
  it "should allow check for value presence" do
    h = SafeHash.new :a => :b
    h.a?.should be_true
    h.b?.should be_false
    
    h.should include(:a)
    h.should_not include(:b)
  end
  
  it "should allow owerride values" do
    h = SafeHash.new :a => :b
    h[:b] = :c
    h.b!.should == :c
  end
  
  it "general behaviour" do
    h = SafeHash.new :key => :value
    
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
    h = SafeHash.new :a => {:a => :b}
    
    h.a.a.should == :b
    h.a.missing.b.c('missing').should == 'missing'
  end
  
  it "should require setting if ! used" do
    h = SafeHash.new :a => :v, :b => {:c => :v}
    
    h.a!.should == :v
    h.b.c!.should == :v
    h.b!.c!.should == :v
    
    lambda{h.j!}.should raise_error(/No key j/) 
    lambda{h.j.b.c!}.should raise_error(/No key c/)
  end
  
  it "should be able to update itself" do
    h = SafeHash.new 
    h.b?.should be_false
    h[:a] = :a
    h.a!.should == :a
  end
  
  it "should implement include?" do
    h = SafeHash.new :a => :b
    h.include?(:a).should be_true
    h.include?('a').should be_true
    h.include?(:b).should be_false

    h.b.include?(:a).should be_false
  end
end