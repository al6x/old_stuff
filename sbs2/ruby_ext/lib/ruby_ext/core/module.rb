Module.class_eval do
  def alias name = nil
    if name
      name.must.be_a String
      name.must.be_present
      @alias = name.to_s
    else
      @alias ||= self.name.split('::').last
    end
  end

  def is?(base)
    ancestors.include?(base)
  end

  def namespace
    if @module_namespace_cached
      @module_namespace
    else
      @module_namespace_cached = true
      @module_namespace = Module.namespace_for name
    end
  end

  def self.namespace_for class_name
    @namespace_for_cache ||= {}
    unless @namespace_for_cache.include? class_name
      list = class_name.split("::")
      @namespace_for_cache[class_name] = if list.size > 1
        list.pop
        eval list.join("::"), TOPLEVEL_BINDING, __FILE__, __LINE__
      else
        nil
      end
    end
    @namespace_for_cache[class_name]
  end

  def metaclass
    class << self; self end
  end

  def metaclass_eval &block
    metaclass.class_eval &block
  end

  def inheritable_accessor attribute_name, default_value
    raise "Can be used only for Class and Module" unless self.class.is? Module

    iv_name = "@#{attribute_name}"
    iv_defined = "@#{attribute_name}_defined"

    define_method attribute_name do
      unless instance_variable_get(iv_defined)
        iv = nil
        ancestors[1..-1].each do |a|
          if a.respond_to?(attribute_name) and (value = a.send(attribute_name))
            iv = value.deep_clone
            break
          end
        end
        iv ||= default_value.deep_clone
        instance_variable_set iv_name, iv
        instance_variable_set iv_defined, true
        iv
      else
        instance_variable_get iv_name
      end
    end

    define_method "#{attribute_name}=" do |value|
      instance_variable_set iv_name, value
      instance_variable_set iv_defined, true
    end
  end

  METHOD_ESCAPE_SYMBOLS = {
    '=='  => 'assign',
    '>'   => 'gt',
    '<'   => 'lt',
    '>='  => 'gte',
    '<='  => 'lte',
    '?'   => 'qst',
    '!'   => 'imp',
    '<=>' => 'lorg',
    '*'   => 'mp',
    '+'   => 'add',
    '-'   => 'sub',
    '='   => 'assign',
    '**'  => 'pw',
    '=~'  => 'sim',
    '[]'  => 'sb'
  }

  def escape_method method
    m = method.to_s.clone
    METHOD_ESCAPE_SYMBOLS.each{|from, to| m.gsub! from, to}
    raise "Invalid method name '#{method}'!" unless m =~ /^[_a-zA-Z0-9]+$/
    m.to_sym
  end

  def attr_required *attrs
    attrs.each do |attr|
      iv_name = :"@#{attr}"
      define_method attr do
        variable = instance_variable_get iv_name
        raise "attribute :#{attr} not defined on #{self}!" if iv_name == nil
        variable
      end
    end
  end

  public :include, :define_method

  # Copied from rails.
  def delegate *methods
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end

    if options[:prefix] == true && options[:to].to_s =~ /^[^a-z_]/
      raise ArgumentError, "Can only automatically set the delegation prefix when delegating to a method."
    end

    prefix = options[:prefix] && "#{options[:prefix] == true ? to : options[:prefix]}_" || ''

    file, line = caller.first.split(':', 2)
    line = line.to_i

    methods.each do |method|
      on_nil =
        if options[:allow_nil]
          'return'
        else
          %(raise "#{self}##{prefix}#{method} delegated to #{to}.#{method}, but #{to} is nil: \#{self.inspect}")
        end

      module_eval(<<-EOS, file, line - 5)
        if instance_methods(false).map(&:to_s).include?("#{prefix}#{method}")
          remove_possible_method("#{prefix}#{method}")
        end

        def #{prefix}#{method}(*args, &block)               # def customer_name(*args, &block)
          #{to}.__send__(#{method.inspect}, *args, &block)  #   client.__send__(:name, *args, &block)
        rescue NoMethodError                                # rescue NoMethodError
          if #{to}.nil?                                     #   if client.nil?
            #{on_nil}                                       #     return # depends on :allow_nil
          else                                              #   else
            raise                                           #     raise
          end                                               #   end
        end                                                 # end
      EOS
    end
  end
end