Object.class_eval do
  def self; self end

  def present?
    !blank?
  end

  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  # def metaclass &block
  #   (class << self; self; end)
  # end
  # def metaclass_eval &block
  #   metaclass.class_eval(&block)
  #   self
  # end

  def respond_to method, *args
    respond_to?(method) ? send(method, *args) : nil
  end

  def try method, *args, &block
    self && self.send(method, *args, &block)
  end

  alias_method :instance_variable_names, :instance_variables

  public :extend
end