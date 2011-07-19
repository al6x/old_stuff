class Abstract
  def initialize dir
    @dir = File.expand_path(dir)
  end
  
  # def config options = {}
  #   rad.config.merge_config! "#{dir}/config/config.yml", options
  # end
  
  def routes
    routes_file = "#{dir}/config/routes.rb"
    load routes_file if File.exist? routes_file
  end
  
  def locales
    I18n.load_path += Dir["#{dir}/config/locales/**/*.{rb,yml}"]
    I18n.load_path += Dir["#{dir}/config/locales/*.{rb,yml}"]
  end
  
  protected        
    attr_reader :dir #, :after_config, :after_environment
end