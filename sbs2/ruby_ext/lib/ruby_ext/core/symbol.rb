Symbol.class_eval do
  def <=> other
    self.to_s <=> other.to_s
  end

  def + other
    (self.to_s + other.to_s).to_sym
  end

  def blank?; to_s.blank? end
end