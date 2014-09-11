class Module
  def namespace
    if @module_namespace_defined
      @module_namespace
    else
      @module_namespace_defined = true
      @module_namespace = Module.namespace_for name
    end
  end
  
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
  
  def self.namespace_for class_name
    list = class_name.split("::")
    if list.size > 1
      list.pop
      return eval list.join("::"), TOPLEVEL_BINDING, __FILE__, __LINE__			
    else
      return nil
    end
  end
  
  def wrap_method( sym, prefix = "old_", &blk )
    old_method = "#{prefix}_#{sym}".to_sym
    alias_method old_method, sym
    define_method(sym) do |*args|
      instance_exec(old_method, *args, &blk)
    end
  end
  
  def is?(base)
    ancestors.include?(base)
  end
  
  def resource_exist? resource_name		
    self_ancestors_and_namespaces do |klass|
      return true if RubyExt::Resource.resource_exist? klass, resource_name					
    end
    return false		
  end
  
  def [] resource_name
    self_ancestors_and_namespaces do |klass|
      if RubyExt::Resource.resource_exist? klass, resource_name
        return RubyExt::Resource.resource_get(klass, resource_name)
      end	
    end
    raise RubyExt::Resource::NotExist, "Resource '#{resource_name}' for Class '#{self.name}' doesn't exist!", caller
  end
  
  def []= resource_name, value
    RubyExt::Resource.resource_set self.name, resource_name, value
  end
  
  def inherit *modules
    modules.each do |amodule|
      include amodule
      
      processed = []
      amodule.ancestors.each do |a|			
        if a.const_defined? :ClassMethods				
          class_methods = a.const_get :ClassMethods
          next if processed.include? class_methods
          processed << class_methods
          extend class_methods
        end
      end
    end
  end      
end