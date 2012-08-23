module RubyExt::OpenConstructor
  def set values, list = nil
    unless list
      if values.is_a? Hash
        values.each do |k, v|
          self.respond_to "#{k}=", v
        end
      else
        values.instance_variables.each do |name|
          accessor = "#{name[1..name.size]}="
          if self.respond_to? accessor
            self.send accessor, values.instance_variable_get(name)
          end
        end
      end
    else
      if values.is_a? Hash
        values.each do |k, v|
          self.respond_to "#{k}=", v if list.include? k
        end
      else
        values.instance_variables.each do |name|
          accessor = name[1..name.size]
          if list.include?(accessor.to_sym)
            accessor = "#{accessor}="
            if self.respond_to?(accessor)
              self.send accessor, values.instance_variable_get(name)
            end
          end
        end
      end
    end
    return self
  end

  def set! values
    values.each do |k, v|
      self.send "#{k}=", v
    end
    return self
  end

  def to_hash
    hash = {}
    instance_variables.each do |name|
      hash[name[1..name.size].to_sym] = instance_variable_get name
    end
    return hash
  end
end