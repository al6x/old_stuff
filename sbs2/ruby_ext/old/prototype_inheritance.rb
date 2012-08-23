#
# Fix for ruby's broken include.
# Included modules doesn't propagated to its children.
#
# Test case:
# module A; end
# module B
#   include A
# end
#
# module Plugin; end
# A.send(:include, Plugin)
#
# p "Ancestors of A: " + A.ancestors.join(', ') # => "Ancestors of A: A, Plugin"
# p "Ancestors of B: " + B.ancestors.join(', ') # => "Ancestors of B: B, A" << NO PLUGIN!
#
Module.class_eval do
  def directly_included_by
    @directly_included_by ||= Set.new
  end

  def fixed_include mod
    unless mod.directly_included_by.include? self
      mod.directly_included_by.add self
    end

    include mod
    directly_included_by.each do |child|
      child.fixed_include self
    end
  end
end


#
# Prototypes
#
Class.class_eval do
  def prototype
    unless @prototype
      unless const_defined? :Prototype
        class_eval "module Prototype; end", __FILE__, __LINE__
      end
      @prototype = const_get :Prototype

      fixed_include @prototype
    end
    @prototype
  end

  def class_prototype
    unless @class_prototype
      unless const_defined? :ClassPrototype
        class_eval "module ClassPrototype; end", __FILE__, __LINE__
      end
      @class_prototype = const_get :ClassPrototype

      (class << self; self end).fixed_include @class_prototype
    end
    @class_prototype
  end
end


#
# Inheritance logic
#
class Class
  def define_instance_methods &block
    prototype.class_eval &block
    # self.include prototype
  end

  def define_class_methods &block
    self.class_prototype.class_eval &block
    # self.extend self.class.prototype
  end

  def inherit *classes
    classes.each do |klass|
      raise "You can inherit classes only ('#{klass}')!" unless klass.class == Class

      prototype.fixed_include klass.prototype
      # self.include prototype

      class_prototype.fixed_include klass.class_prototype
      # (class << self; self end).include class_prototype

      # callback
      klass.inherited self if klass.respond_to? :inherited
    end
  end
end


#
# Sugar
#
Class.class_eval do
  alias_method :instance_methods_without_prototype, :instance_methods
  def instance_methods *args, &block
    if block
      define_instance_methods &block
    else
      instance_methods_without_prototype
    end
  end

  alias_method :class_methods, :define_class_methods
end