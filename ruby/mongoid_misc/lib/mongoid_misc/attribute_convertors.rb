module Mongoid::AttributeConvertors
  extend ActiveSupport::Concern
  
  CONVERTORS = {
    line: {
      from_string: -> s {(s || "").split(',').collect{|s| s.strip}},
      to_string:   -> v {v.join(', ')}
    },
    column: {
      from_string: -> s {(s || "").split("\n").collect{|s| s.strip}},
      to_string:   -> v {v.join("\n")}
    },
    yaml: {
      from_string: -> s {YAML.load s rescue {}},
      to_string:   -> v {              
        # Mongoid uses it's internal Hash that doesn't support to_yaml
        hash = {}; v.each{|k, v| hash[k] = v}               
        hash.to_yaml.strip
      }
    },
    json: {
      from_string: -> s {JSON.parse s rescue {}},
      to_string:   -> v {
        # Mongoid uses it's internal Hash that doesn't support to_yaml
        hash = {}; v.each{|k, v| hash[k] = v}               
        hash.to_json.strip
      }
    }
  }
  
  module ClassMethods
    # supporf for :as_string option
    def field name, options = {}                       
      if converter_name = options[:as_string]
        available_as_string name, converter_name
        attr_protected "#{name}_as_string".to_sym if options[:protected]            
      end
      
      super
    end
    
    def available_as_string name, converter_name
      converter = CONVERTORS[converter_name]
      raise "unknown converter name :#{converter_name} for :#{name} field!" unless converter
      
      from_string, to_string = converter[:from_string], converter[:to_string]
      name_as_string = "#{name}_as_string".to_sym
      define_method name_as_string do
        cache[name_as_string] ||= to_string.call(send(name))
      end
      
      define_method "#{name_as_string}=" do |value|
        cache.delete name_as_string                        
        self.send "#{name}=", from_string.call(value)
      end
    end
    
    def available_as_yaml name
      raise "delimiter not specified for :#{name} field!" unless delimiter
      method = "#{name}_as_string"
      define_method method do
        self.send(name).join(delimiter)
      end
      define_method "#{method}=" do |value|            
        value = (value || "").split(delimiter.strip).collect{|s| s.strip}
        self.send "#{name}=", value
      end
    end
  end
  
end