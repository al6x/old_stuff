class OpenObject < Hash
  #
  # delete methods
  #
  PUBLIC_METHODS = %w(
    as send each each_pair size is_a? clone dup empty? blank? present? merge merge! stringify_keys stringify_keys! symbolize_keys symbolize_keys! to_query
  ).collect{|m| m.to_sym}
  PUBLIC_METHODS_RE = /(^__|^object_|^must|^stub)/
  protected(*public_instance_methods.select{|m| !PUBLIC_METHODS.include?(m) and m !~ PUBLIC_METHODS_RE})

  def inspect
    # "#<#{self.class}:#{self.object_id} #{super}>"
    "<#{super}>"
  end

  def to_a; super end

  def to_proc; super end

  def to_openobject deep = false
    unless deep
      self
    else
      r = OpenObject.new
      each do |k, v|
        r[k] = if v.is_a? Hash
          v.to_openobject
        else
          v
        end
      end
      r
    end
  end
  alias_method :to_oo, :to_openobject

  def each &block; super(&block) end

  def merge other
    d = dup
    other.each{|k, v| d[k] = v}
    d
    # d = dup
    # d.send(:update, other)
    # d
  end

  def merge! other
    other.each{|k, v| self[k] = v}
  end

  def update other
    other.to_hash.each{|k,v| self[k.to_sym] = v}
    self
  end

  def delete key
    super key.to_sym
  end

  def == other
    return false unless other.respond_to?(:each) and other.respond_to?(:size) and other.respond_to?(:[]) and self.size == other.size
    other.each do |k, v|
      return false unless self[k] == v
    end
    true
  end

  def []= k, v
    super k.to_sym, v
  end

  def [] k
    super k.to_sym
  end

  def include? k
    super k.to_sym
  end

  def to_hash deep = false
    unless deep
      {}.update(self)
    else
      h = {}
      each do |k, v|
        if v.is_a? OpenObject
          h[k] = v.to_hash(true)
        else
          h[k] = v
        end
      end
      h
    end
  end

  def to_json *args
    to_hash.to_json *args
  end

  # hack to works well with RSpec
  def should; super end
  def should_not; super end

  def respond_to? m
    true
  end

  def self.initialize_from hash, deep = false
    unless deep
      ::OpenObject.new.update hash
    else
      r = ::OpenObject.new
      hash.each do |k, v|
        r[k] = if v.is_a? Hash
          v.to_openobject
        else
          v
        end
      end
      r
    end
  end

  # support :extract_options for OpenObject (Rails integration)
  def extractable_options?; true end

  def deep_clone
    clone = super
    clone.clear
    each{|k, v| clone[k.deep_clone] = v.deep_clone}
    clone
  end

  protected
    def method_missing m, arg = nil, &block
      type = m[-1,1]
      if type == '='
        self[m[0..-2]] = arg
      elsif type == '!'
        warn 'deprecated'
        self[m[0..-2]]
      elsif type == '?'
        !self[m[0..-2]].blank?
      else
        self[m]
      end
    end
end