class Time
  def eql? o
    return true if equal?(o)
    self.class == o and self == o
  end

  def == o
    return true if equal?(o)
    o.respond_to?(:to_i) and to_i == o.to_i
  end
end