ActionController::Base.send :class_eval do
  protected
  
  DO_NOT_PERSIST = ['_', '_method']

  def default_url_options options = {}
    persistent_params = {}
    
    if options
      options = options.stringify_keys if options
      global_persistent_params = ActionController::Base.global_persistent_params
    
      if Thread.current[:persist_params] or options.delete(:persist)
        params.each do |key, value|
          persist = (
            (key =~ /^_/) and
            !(options.include?(key) or DO_NOT_PERSIST.include?(key))
          ) or global_persistent_params.include?(key)

          persistent_params[key] = value if persist
        end
      end
        
      # global_persistent_params.each do |key, value|
      #   persistent_params[key] = value unless options.include?(key)
      # end
    end
    
    return persistent_params
  end
  
  def persist_params &block
    before = Thread.current[:persist_params]
    begin
      Thread.current[:persist_params] = true
      block.call
    ensure
      Thread.current[:persist_params] = before
    end
  end 
  helper_method :persist_params
  
  def do_not_persist_params &block
    before = Thread.current[:persist_params]
    begin
      Thread.current[:persist_params] = false
      block.call
    ensure
      Thread.current[:persist_params] = before
    end
  end 
  helper_method :do_not_persist_params
  
  # def prepare_global_persistent_params
  #   persistent_params = ActionController::Base.global_persistent_params
  #   prefix_params = ActionController::Base.global_path_prefix
  #   params = self.params.stringify_keys
  #   params.each do |key, value|
  #     if persistent_params.include?(key) and !prefix_params.include?(key)
  #       global_persistent_params[key] = value
  #     end
  #   end
  # end
  # def global_persistent_params
  #   @global_persistent_params ||= {}
  # end
  # before_filter :prepare_global_persistent_params
  
  class << self
    def global_persistent_params= params
      @global_persistent_params = params.collect &:to_s
    end
    
    def global_persistent_params
      @global_persistent_params ||= []
    end
    
    def persist_params *args
      if args.empty?
        around_filter :persist_params
      elsif args.first.is_a? Hash
        # args.first.should! :be_a, Hash
        around_filter :persist_params, args.first
      else
        around_filter :persist_params, :only => args.first
      end
    end
  end
end

# allows to install a global_persistent_params to the route set by calling: map.global_persistent_params 'locale'
ActionController::Routing::RouteSet::Mapper.class_eval do
  def global_persistent_params *args
    ActionController::Base.global_persistent_params = args
  end
end