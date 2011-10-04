require 'spec'

require 'ruby_ext'
require 'active_support'
require "#{File.dirname __FILE__}/../../lib/abstract_interface/haml_builder"

require 'facets/openobject'


# 
# Don't use should ==, it doesn't works with OpenObject
# 
describe "HamlBuilder use cases" do  
  class TemplateStub
    def self.capture &block
      block.call
      self.output
    end
    
    class << self
      attr_accessor :output
    end
  end
  
  def build *args, &block
    opt = args.extract_options!
    args.size.should! :be_in, 0..1
    opt[:content] = args.first if args.size == 1
    
    r = AbstractInterface::HamlBuilder.get_input(TemplateStub, opt, &block)
    convert_to_hashes r
  end
  
  def convert_to_hashes value
    if value.is_a? OpenObject
      r = {}
      value.each do |k, v|
        r[k] = convert_to_hashes v
      end
      r
    else
      value
    end
  end
  
  it "hash" do
    (build do |o|
      o.a :b
    end).should == {:a => :b}
  
    build(:a => :b).should == {:a => :b}
  end
  
  it "array" do
    (build do |a|
      a.add 1
      a.add 2
    end).should == {:content => [1, 2]}
    
    (build do |o|
      o.a :b
      o.ar do |a|
        a.add 1
        a.add 2
      end      
    end).should == {:a => :b, :ar => [1, 2]}
  end
  
  it "capture" do
    build("value").should == {:content => "value"}
    
    (build do
      TemplateStub.output = "value"
    end).should == {:content => "value"}
    
    (build do |o|
      o.content do
        TemplateStub.output = "value"
      end
    end).should == {:content => "value"}
    
    (build do |o|
      o.value do
        TemplateStub.output = "value"
      end
    end).should == {:value => "value"}
  end
  
  it "invalid usage" do
    lambda{
      build "value" do
        TemplateStub.output = "value"
      end
    }.should raise_error(/Invalid usage!/)
  end
  
  it "merge" do
    (build :a => :b do
      TemplateStub.output = "value"
    end).should == {:a => :b, :content => "value"}
    
    (build :a => :b do |o|
      o.c :d
    end).should == {:a => :b, :c => :d}
  end
  
  it "nested" do
    (build :a => :b do |o|
      o.a do |o|
        o.b :c
      end
    end).should == {
      :a => {:b => :c}
    }
  end
  
  it "complex" do
    (build :a => :b do |o|      
      o.hs do |h|
        h.c :d
      end
      o.ar do |a|
        a.add 1        
        a.add 2
      end
      o.html do
        TemplateStub.output = "value"
      end
    end).should == {
      :a => :b,
      :hs => {:c => :d},
      :ar => [1, 2],
      :html => 'value'
    }
  end
end