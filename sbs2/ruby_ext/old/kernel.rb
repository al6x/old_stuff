Kernel.class_eval do
  # Removes the namespace (exact match and underscored) of given class (or self) from stacktrace
  def raise_without_self *args
    error, message, klasses = nil
    if args.size == 1
      error = RuntimeError
      message = args[0]
      klasses = [self]
    elsif args.size == 2
      message, klasses = args
      error = RuntimeError

      klasses = Array(klasses)
      klasses << self
    elsif args.size == 3
      error, message, klasses = args

      klasses = Array(klasses)
      klasses << self
    else
      raise RuntimeError, "Invalid arguments!", caller
    end

    klasses.collect!{|c| (c.class == Class or c.class == Module or c.class == String) ? c : c.class}

    # obtaining the namespace of each class
    klasses.collect! do |c|
      if c.respond_to? :namespace
        c = c.namespace while c.namespace
        c
      else
        c
      end
    end

    # building regexp
    skip = []
    klasses.each do |c|
      skip.push(/\/#{c.to_s}/) # exact match
      skip.push(/\/#{c.to_s.underscore}/) # underscored
    end

    # cleaning stacktrace
    stack = caller.select{|path| !skip.any?{|re| re =~ path}}

    raise error, message, stack
  end
end