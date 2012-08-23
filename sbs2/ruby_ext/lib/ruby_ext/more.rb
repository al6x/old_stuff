require 'ruby_ext/core'

require 'ruby_ext/more/must'

require 'set'

# Lazy loading.
autoload :UserError, 'ruby_ext/more/user_error'
module RubyExt
  %w(Callbacks CallbacksProxy DeclarativeCache Observable OpenConstructor Tuple).each do |const|
    autoload const, "ruby_ext/more/#{const.underscore}"
  end
end

# Declarative cache.
Module.class_eval do
  def cache_method *methods
    ::RubyExt::DeclarativeCache.cache_method self, *methods
  end

  def cache_method_with_params *methods
    ::RubyExt::DeclarativeCache.cache_method_with_params self, *methods
  end

  def clear_cache obj
    obj.instance_variables.each do |iv|
      obj.send :remove_instance_variable, iv if iv =~ /_cache$/ or iv =~ /_cache_check$/
    end
  end
end

# Printing with multiple arguments.
Kernel.class_eval do
  alias_method :old_p, :p
  def p *args
    puts args.collect{|a| a.inspect}.join(' ')
    return *args
  end
end