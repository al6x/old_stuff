require 'monitor'

Module.class_eval do
  def synchronize_method *methods
    methods.each do |method|
      raise "can't synchronize system method #{method}" if method =~ /^__/

      als = "sync_#{escape_method(method)}".to_sym

      raise "can't synchronize the '#{method}' twice!" if instance_methods.include?(als)

      alias_method als, method
      script = "\
def #{method} *p, &b
  @monitor ||= Monitor.new
  @monitor.synchronize{#{als} *p, &b}
end"
      class_eval script, __FILE__, __LINE__
    end
  end

  def synchronize_all_methods include_super = false
    methods = self.instance_methods(include_super).collect{|m| m}
    synchronize_method *methods
  end
end