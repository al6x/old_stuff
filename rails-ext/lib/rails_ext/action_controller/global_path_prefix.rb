# 
# Global path prefix (hack with relative_url_root)
# 
GLOBAL_PATH_PREFIX_DELIMITER = '-'
ActionController::Base.send :class_eval do 
  def self.global_path_prefix
    @global_path_prefix ||= []
  end
  
  def self.global_path_prefix= list
    @global_path_prefix = list.collect{|v| v.to_s}
  end
  
  cattr_accessor :_relative_url_root  
end
ActionController::Base._relative_url_root = ActionController::Base.relative_url_root || ""

# 
# Generation
# 

# routes
ActionController::Base.send :class_eval do
  around_filter :hack_relative_url_root
  protected 
  
  # preparing relative_url_root from params
  def hack_relative_url_root
    begin
      update_relative_url_root!
      yield
    ensure
      ActionController::Base.relative_url_root = ActionController::Base._relative_url_root
    end
  end
  
  def update_relative_url_root!
    prefix_params = []
    ActionController::Base.global_path_prefix.each do |name|
      unless (param = params[name]).blank?
        prefix_params << [name, CGI.escape(param)]
      end
    end
    prefix = prefix_params.collect{|name, param|  "#{param}#{GLOBAL_PATH_PREFIX_DELIMITER}#{name}"}.join('/')
    ActionController::Base.relative_url_root = ActionController::Base._relative_url_root + (prefix.blank? ? "" : "/" + prefix)
  end
end

# 
# Usability
# allows to install a global_path_prefix to the route set by calling: map.global_path_prefix 'locale'
ActionController::Routing::RouteSet::Mapper.class_eval do
  def global_path_prefix *args
    ActionController::Base.global_path_prefix = args
  end
end