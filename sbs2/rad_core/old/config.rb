class Rad::Config
  def merge_config! path, options = {}
    h = self.class.load_config path, options
    Merger.new(self, options).merge! h
  end

  def apply_to! component_name, component, defaults = {}
    component_name.must.be_a Symbol
    merger = Merger.new component
    merger.merge! defaults
    if cfg = instance_variable_get(:"@#{component_name}")
      raise "invalid config for :#{component_name} component!" unless cfg.is_a? Hash
      merger.merge! cfg
    end
    component
  end

  protected

  loads and merges config files in the following order (if any exist) :
  config.default.yml, config.yml, config.environment.yml

  def self.load_config path, options = {}
    raise "config file must have .yml extension (#{path})!" unless path.end_with? '.yml'
    default_path = path.sub(/yml$/, 'default.yml')
    current_environment_path = path.sub(/yml$/, "#{rad.mode}.yml")

    config = {}
    [
      default_path,
      path,
      current_environment_path
    ].each do |cfile|
      if File.exist? cfile
        h = YAML.load_file cfile
        h.must.be_a Hash
        Merger.new(config, options).merge! h
      end
    end
    config
  end

  class SafeWraper
    attr_reader :target
    def initialize target
      @target = target
    end
    delegate :[]=, to: :target

    def method_missing m, *args
      if m =~ /=$/
        target.send(m, *args)
      else
        target.instance_variable_get :"@#{m}"
      end
    end
  end

  module Helper
    module ClassMethods
      def attr_required *keys
        keys.each do |k|
          define_method(k){instance_variable_get(:"@#{k}") || raise("key :#{k} not defined!")}
        end
      end
    end

    def safe
      @safe ||= ::Rad::Config::SafeWraper.new self
    end
  end
  inherit Helper


  class Merger
    def initialize obj, options = {}
      options.validate_options! :deep, :override, :blank
      @options = options
      @deep = options.include?(:deep) ? options[:deep] : true
      @override = options.include?(:override) ? options[:override] : true
      @blank = options[:blank] || false
      raise "invalid options, can't do both :blank and :override simultaneously!" if @blank and @override

      @obj = obj
    end

    def merge! hash
      ensure_no_disambiquities hash
      hash.each do |k, v|
        k = k.to_sym
        v = v.symbolize_keys_deeply if @deep and v.is_a?(Hash)

        if old_v = get(k)
          if @deep and old_v.is_a?(Hash) and v.is_a?(Hash)
            Merger.new(old_v, @options).merge!(v)
          else
            if @blank
              # do nothing
            elsif @override
              set k, v
            else
              raise "can't override :#{k} config key!" unless @override
            end
          end
        else
          set k, v
        end
      end
      self
    end

    protected
      def ensure_no_disambiquities hash
        hash.each do |k, v|
          if k.is_a? Symbol
            raise "key #{k} present as String and Symbol!" if hash.include? k.to_s
          elsif k.is_a? String
            raise "key #{k} present as String and Symbol!" if hash.include? k.to_sym
          else
            raise "invalid key #{k} (key can be only Symbol or String)"
          end
        end
      end

      def get key
        @obj.is_a?(Hash) ? @obj[key] : @obj.instance_variable_get("@#{key}")
      end

      def set key, value
        @obj.is_a?(Hash) ? @obj[key] = value : @obj.instance_variable_set("@#{key}", value) #@obj.send("#{key}=", value)
      end
  end
end