Hash.class_eval do
  def subset *keys, &block
    keys = keys.first if keys.first.is_a? Array
    h = {}
    if keys
      self.each do |k, v|
        h[k] = v if keys.include? k
      end
    else
      self.each do |k, v|
        h[k] = v if block.call k
      end
    end
    h
  end

  def validate_options! *valid_options
    unknown_options = keys - valid_options
    raise "unknown options :#{unknown_options.join(': ')}!" unless unknown_options.empty?
  end

  def reverse_merge(other_hash)
    other_hash.merge(self)
  end

  def reverse_merge!(other_hash)
    merge!( other_hash ){|key,left,right| left }
  end

  # Haml relies on :inspect default format and it brokes haml, but I prefer new hash notation,
  # disable it if You use Haml.
  # unless $dont_extend_hash_inspect
  #   def inspect
  #     "{" + collect{|k, v| "#{k}: #{v}"}.join(', ') + "}"
  #   end
  #   alias_method :to_s, :inspect
  # end

  alias_method :blank?, :empty?

  # OpenObject.

  def to_openobject deep = false
    OpenObject.initialize_from self, deep
  end
  alias_method :to_oo, :to_openobject

  alias_method :eql_without_oo, :==
  def == other
    true if self.equal? other
    other == self if other.is_a? OpenObject
    eql_without_oo other
  end

  class << self
    def symbolize obj
      convert_keys obj, :to_sym
    end

    def stringify obj
      convert_keys obj, :to_s
    end

    protected
      def convert_keys obj, method
        if obj.is_a? Hash
          {}.tap{|h| obj.each{|k, v| h[k.send(method)] = convert_keys v, method}}
        elsif obj.is_a? Array
          obj.collect{|v| convert_keys v, method}
        else
          obj
        end
      end
  end
end