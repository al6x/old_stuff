require 'date'

Object.class_eval do
  def deep_clone
    clone = self.clone
    instance_variables.each do |name|
      value = instance_variable_get name
      clone.instance_variable_set name, value.deep_clone
    end
    clone
  end
end

Hash.class_eval do
  def deep_clone
    clone = super
    clone.clear
    each{|k, v| clone[k.deep_clone] = v.deep_clone}
    clone
  end
end

Struct.class_eval do
  def deep_clone
    clone = super
    clone.clear
    each_pair{|k, v| clone[k.deep_clone] = v.deep_clone}
    clone
  end
end

Array.class_eval do
  def deep_clone
    clone = super
    clone.clear
    each{|v| clone << v.deep_clone}
    clone
  end
end

[Class, Proc, Regexp].each do |klass|
  klass.class_eval do
    def clone; self end
    alias_method :deep_clone, :clone
  end
end

[Symbol, TrueClass, FalseClass, Numeric, TrueClass, FalseClass, NilClass].each do |klass|
  klass.send :alias_method, :clone, :self
end

[String, Symbol, Range, Regexp, Time, Date].each do |klass|
  klass.send :alias_method, :deep_clone, :clone
end