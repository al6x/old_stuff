Module.class_eval do
  def each_namespace &block
    current = namespace
    while current do
      block.call current
      current = current.namespace
    end
  end

  def each_ancestor include_standard = false, &block
    if include_standard
      ancestors.each{|a| block.call a unless a == self}
    else
      exclude = [self, Object, Kernel]
      ancestors.each do |a|
        block.call a unless exclude.include? a
      end
    end
  end

  def self_ancestors_and_namespaces &b
    b.call self
    each_ancestor &b
    each_namespace &b
  end
end