module Rad::Filters
  inherit RubyExt::Callbacks

  module ClassMethods
    def before *args, &block
      opt = args.extract_options!
      if block
        set_callback :action, :before, opt, &block
      else
        args.each{|executor| set_callback :action, :before, executor, opt}
      end
    end

    def around *args, &block
      opt = args.extract_options!
      if block
        set_callback :action, :around, opt, &block
      else
        args.each{|executor| set_callback :action, :around, executor, opt}
      end
    end

    def after *args, &block
      opt = args.extract_options!
      if block
        set_callback :action, :after, opt, &block
      else
        args.each{|executor| set_callback :action, :after, executor, opt}
      end
    end
  end
end