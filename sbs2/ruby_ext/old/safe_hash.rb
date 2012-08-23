# require 'singleton'

class SafeHash < BasicObject
  attr_reader :hash

  alias_method :send, :__send__

  def initialize hash = {}
    reinitialize hash
  end

  def []= key, value
    value = ::SafeHash.new value if value.is_a? ::Hash
    @hash[key.to_sym] = value
  end

  # def set! key, value
  #   value = ::SafeHash.new value if value.is_a? ::Hash
  #   @hash[key.to_sym] = value
  # end
  # def set *args; raise "you probably mistyped :set! method!" end

  def include? key
    @hash.include? key.to_sym
  end

  def tap &b
    b.call self
    self
  end

  def [] key, if_not_exist = ::NotDefined
    last = key[-1]
    if last == '!'
      key = key[0..-2].to_sym
      if @hash.include? key
        @hash[key]
      else
        raise "no key :#{key}"
      end
    elsif last == '?'
      key = key[0..-2].to_sym
      @hash.include? key
    else
      key = key.to_sym
      if @hash.include? key
        @hash[key]
      elsif if_not_exist == ::NotDefined
        SafeNil.new key
      else
        return if_not_exist
      end
    end
  end

  def reinitialize hash
    @hash = {}
    merge! hash
    # hash.each do |k, v|
    #   v = ::SafeHash.new v if v.is_a? ::Hash
    #   @hash[k.to_sym] = v
    # end
    # @hash.freeze
  end

  def method_missing m, obj = ::NotDefined, &b
    raise "invalid usage, can't pass block to (:#{m})!" if b
    last = m[-1]
    if last == '='
      self[m[0..-2]] = obj
    else
      self[m, obj]
    end
  end

  def to_yaml *args
    @hash.to_yaml *args
  end

  def inspect
    @hash.inspect
  end

  def delete key
    @hash.delete key.to_sym
  end

  # deep conversion, check and converts nested SafeHashes to Hashes
  def to_hash options = {}
    r = {}
    @hash.each do |k, v|
      k = k.to_s if options[:to_s]
      r[k] = if v.respond_to :is_a_safe_hash?
        v.to_hash options
      else
        v
      end
    end
    r
  end

  def is_a_safe_hash?
    true
  end

  protected
    def reinitialize hash
      @hash = {}
      hash.each do |k, v|
        v = ::SafeHash.new v if v.is_a? ::Hash
        @hash[k.to_sym] = v
      end
      @hash
    end


  class SafeNil < BasicObject
    # include ::Singleton

    def initialize key
      @key = key
    end

    def [] key, if_not_exist = ::NotDefined
      last = key[-1]
      if last == '!'
        raise "no key :#{key}"
      elsif last == '?'
        false
      elsif if_not_exist == ::NotDefined
        SafeNil.new key
      else
        return if_not_exist
      end
    end

    def method_missing m, if_not_exist = ::NotDefined, &b
      raise "invalid usage, can't pass block to (:#{m})!" if b
      last = m[-1]
      if last == '='
        raise "no key '#{@key}'!"
      else
        self[m, if_not_exist]
      end
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

    def to_hash
      {}
    end

    def to_s
      raise "can't convert SafeNil for key '#{@key}' to String!"
    end

    def inspect
      nil.inspect
    end
  end

  protected
    def p *a
      ::Object.send :p, *a
    end
end