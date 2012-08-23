class Module

  # Use cache in :production and don't use in another environments.
  # If no environment given uses non-cached version.
  def cache_method_with_params_in_production method
    escaped_method = escape_method(method)
    method_with_cache, method_without_cache = "#{escaped_method}_with_cache", "#{escaped_method}_without_cache"
    iv = "@#{escaped_method}_cache"

    # raise "Method '#{method}' already defined!" if instance_methods.include?(method)
    if instance_methods.include?(method_with_cache) or instance_methods.include?(method_without_cache)
      warn "can't cache the :#{method} twice!"
    else
      alias_method method_without_cache, method

      # create cached method
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

      if rad.mode == :production
        alias_method method, method_with_cache
      else
        alias_method method, method_without_cache
      end

      # by default uses non-cached version
      # alias_method method, method_without_cache
    end
  end

end