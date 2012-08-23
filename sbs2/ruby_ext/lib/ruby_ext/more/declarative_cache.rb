module RubyExt::DeclarativeCache
  class << self

    def cache_method klass, *methods
      methods.each do |method|
        klass.class_eval do
          escaped_method = escape_method method
          method_with_cache    = :"#{escaped_method}_with_cache"
          method_without_cache = :"#{escaped_method}_without_cache"
          iv_check = "@#{escaped_method}_cache_check"
          iv       = "@#{escaped_method}_cache"

          alias_method method_without_cache, method

          define_method method_with_cache do |*args|
            raise "You tried to use cache without params for method with \
params (use 'cache_method_with_params' instead)!" unless args.empty?

            unless cached = instance_variable_get(iv)
              unless check = instance_variable_get(iv_check)
                cached = send method_without_cache
                instance_variable_set iv, cached
                instance_variable_set iv_check, true
              end
            end
            cached
          end

          alias_method method, method_with_cache
        end
      end
    end

    def cache_method_with_params klass, *methods
      methods.each do |method|
        klass.class_eval do
          escaped_method = escape_method method
          method_with_cache    = :"#{escaped_method}_with_cache"
          method_without_cache = :"#{escaped_method}_without_cache"
          iv_check = "@#{escaped_method}_cache_check"
          iv       = "@#{escaped_method}_cache"

          alias_method method_without_cache, method

          define_method method_with_cache do |*args|
            unless results = instance_variable_get(iv)
              results = Hash.new(NotDefined)
              instance_variable_set iv, results
            end

            result = results[args]

            if result.equal? NotDefined
              result = send method_without_cache, *args
              results[args] = result
            end

            result
          end

          alias_method method, method_with_cache
        end
      end
    end

  end
end