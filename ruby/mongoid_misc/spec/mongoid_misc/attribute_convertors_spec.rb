require 'mongoid_misc/spec_helper'

describe "Attribute Convertors" do
  with_mongoid
  
  after(:all){remove_constants :TheSample}    
    
  before do
    @convertors = Mongoid::AttributeConvertors::CONVERTORS
    # @convertors.merge(test_convertor: {
    #   from_string: -> s {"from_string: #{s}"},
    #   to_string:   -> v {"to_string: #{v}"}
    # })
  end
  
  it ":line convertor" do      
    v = ['a', 'b']
    str_v = 'a, b'
    @convertors[:line][:from_string].call(str_v).should == v
    @convertors[:line][:to_string].call(v).should == str_v
  end
  
  it ":yaml convertor" do
    v = {'a' => 'b'}
    str_v = v.to_yaml.strip
    
    @convertors[:yaml][:from_string].call(str_v).should == v
    @convertors[:yaml][:to_string].call(v).should == str_v
  end
  
  it ":json convertor" do
    v = {'a' => 'b'}
    str_v = v.to_json.strip
    @convertors[:json][:from_string].call(str_v).should == v
    @convertors[:json][:to_string].call(v).should == str_v
  end
  
  it ":field should generate helper methods if :as_string option provided" do
    class ::TheSample
      include Mongoid::Document
      
      field :tags,           type: Array, default: [], as_string: :line
      field :protected_tags, type: Array, default: [], as_string: :line, protected: true
    end
  
    o = TheSample.new
    
    # get
    o.tags_as_string.should == ''
    o.tags = %w(Java Ruby)
    o.clear_cache
    o.tags_as_string.should == 'Java, Ruby'
    
    # set
    o.tags_as_string = ''
    o.tags.should == []
    o.tags_as_string = 'Java, Ruby'
    o.tags.should == %w(Java Ruby)
    
    # mass assignment
    o.tags = []
    o.update_attributes tags_as_string: 'Java, Ruby'
    o.tags.should == %w(Java Ruby)
    
    # # protection
    o.protected_tags = []
    o.update_attributes protected_tags_as_string: 'Java, Ruby'
    o.protected_tags.should == []
  end
end