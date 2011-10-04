require 'singleton'

class SafeHash < BlankSlate
  attr_reader :hash
  
  def initialize hash = {}
    reinitialize hash
  end
  
  def []= key, value
    value = SafeHash.new value if value.is_a? Hash
    @hash[key.to_s] = value
  end
  
  def include? key
    @hash.include? key.to_s
  end
  
  def [] key, *args
    key = key.to_s
    if key.last == '!'
      key = key[0..key.size-2]
      if (result = @hash[key]).eql? nil       
        raise "No key #{key}"
      else
        result
      end
    elsif key.last == '?'
      key = key[0..key.size-2]
      @hash.include? key
    elsif (result = @hash[key]).eql? nil
      if args.empty?
        SafeNil.instance
      else
        return *args
      end
    else
      result
    end
  end
  
  def reinitialize hash
    @hash = {}
    hash.each do |k, v|
      v = SafeHash.new v if v.is_a? Hash 
      @hash[k.to_s] = v
    end
    # @hash.freeze
  end
  
  def method_missing m, *args
    self[m, *args]
  end
  
  def to_yaml *args
    @hash.to_yaml *args
  end
  
  def inspect
    @hash.inspect
  end
  
  def to_h
    @hash
  end
  
  class SafeNil < BlankSlate
    include Singleton

    def [] key, *args
      if key.to_s.last == '!'
        raise "No key #{key}"
      elsif args.empty?
        SafeNil.instance
      else
        return *args
      end
    end

    def method_missing m, *args
      self[m, *args]
    end
    
    def include? key
      false
    end
    
    def to_b
      false
    end
    
    def to_yaml *args
      nil.to_yaml *args
    end
    
    def to_h
      {}
    end
    
    def inspect
      nil.inspect
    end
  end
end