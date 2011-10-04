# Hack to use dynamic default_scope
class HashPoser < Proc
  include Enumerable
 
  attr_accessor :proc
 
  def initialize &b
    @proc = b
    super &b
  end
 
  def [](key)
    call[key]
  end
 
  def each(*a, &b)
    call.each(*a, &b)
  end
 
  def fetch(key)
    call.fetch(key)
  end
 
  def keys
    call.keys
  end
 
  def merge(*a, &b)
    call.merge(*a, &b)
  end
 
  def to_hash
    call
  end
 
  def to_s
    "#<HashPoser: #{call.inspect}>"
  end
  alias_method :inspect, :to_s
end