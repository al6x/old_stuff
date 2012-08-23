class Rad::Config
  def subset; raise "you probably mistuped, it's config, not hash" end

  def initialize hash = {}
    hash.each do |k, v|
      instance_variable_set :"@#{k}", v
    end
  end

  def deep_clone
    clone = Rad::Config.new
    instance_variable_names.each do |k|
      clone.instance_variable_set k, instance_variable_get(k).deep_clone
    end
    clone
  end
  alias_method :clone, :deep_clone

  protected
    def method_missing m, *args
      if m =~ /=$/
        instance_variable_set :"@#{m[0..-2]}", args.first
      else
        instance_variable_get :"@#{m}"
      end
    end
end