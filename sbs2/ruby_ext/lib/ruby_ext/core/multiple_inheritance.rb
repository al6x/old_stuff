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
class Module
  def directly_included_by
    @directly_included_by ||= {}
  end

  def include2 mod
    # unless mod.directly_included_by.include? self
    mod.directly_included_by[self] = true
    # end

    include mod
    directly_included_by.each do |child, v|
      child.include2 self
    end
  end
end


#
# Inheritance
#
class Module
  def class_prototype
    unless @class_prototype
      ancestor = ancestors[1]
      if(
        !const_defined?(:ClassMethods) or
        (
          const_defined?(:ClassMethods) and ancestor and ancestor.const_defined?(:ClassMethods) and
          const_get(:ClassMethods) == ancestor.const_get(:ClassMethods)
        )
      )
        class_eval "module ClassMethods; end", __FILE__, __LINE__
      end
      @class_prototype = const_get :ClassMethods

      (class << self; self end).include2 @class_prototype
    end
    @class_prototype
  end

  def class_methods &block
    if block
      class_prototype.class_eval &block
      extend class_prototype
    else
      class_prototype.instance_methods
    end
  end

  def inherited &b
    @inherited ||= []
    @inherited << b if b
    @inherited
  end

  def inherit *modules
    modules.each do |mod|
      # Instance Methods
      include2 mod

      # Class Methods
      unless self.class_prototype == mod.class_prototype
        if self.class == Module
          class_prototype.include2 mod.class_prototype
        else
          (class << self; self end).include2 mod.class_prototype
        end
      end

      # Inherited callback
      if self.class == Class
        mod.ancestors.each do |anc|
          anc.inherited.each{|b| self.instance_eval &b}
        end
      end
    end
  end
end