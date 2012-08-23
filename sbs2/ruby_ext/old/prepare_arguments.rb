class ArgumentsParser
  class << self
    def register method, arguments
      # check and prepare metadata
      arguments.collect!{|meta| meta.is_a?(Hash) ? meta : {type: meta}}
      arguments.each{|meta| meta.must.include :type}

      # register
      @registry ||= {}
      @registry[method] = arguments
    end

    def parse_arguments_for method, *args, &block
      metadata = @registry[method]
      index = 0
      parsed_args = metadata.collect do |options|
        send options[:type], args, block, options, index, (index == metadata.size - 1)
      end
      args.must.be_empty
      return parsed_args
    end

    protected
    def string args, block, options, index, last
      object(args, block, options, index, last) || ""
    end

    def object args, block, options, index, last
      a = if range = options[:range]
        if range == :except_last_hash
          if args.size == 1 and args.last.is_a? Hash
            nil
          else
            args.shift
          end
        else
          must.be_never_called
        end
      else
        args.shift
      end

      a = _common_options a, options
      a
    end

    def array args, block, options, index, last
      a = if last
        args
      elsif range = options[:range]
        if range == :except_last_hash
          if args.last.is_a? Hash
            tmp = args[0..-2]
            args[0..-2] = nil
            tmp
          else
            tmp = args[0..-1]
            args.clear
            tmp
          end
        else
          must.be_never_called
        end
      else
        args.shift
      end

      a = _common_options a, options
      a ||= []
      a = [a] unless a.is_a?(Array)
      a
    end

    def hash args, block, options, index, last
      a = object(args, block, options, index, last) || {}
      a.must.be_a Hash
      a
    end

    def _common_options a, options
      a.must_not.be_nil if options[:require]
      if (default = options[:default]) and a.eql?(nil)
        a = default
      end
      a
    end
  end
end

Module.class_eval do
  def prepare_arguments_for method, *args
    # Register parsers
    ArgumentsParser.register method, args

    # Wrap method
    old_method = :"#{method}_wparg"
    alias_method old_method, method
    code = <<END
def #{method} *args, &block
#{old_method} *ArgumentsParser.parse_arguments_for(:#{method}, *args), &block
end
END
    class_eval code, __FILE__, __LINE__
  end
end