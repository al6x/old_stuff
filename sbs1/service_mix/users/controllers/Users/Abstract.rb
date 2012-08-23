class Abstract
  inherit Crystal::HttpController
  
  def call
    render :inline => 'ok'
  end
  
  acts_as_localized
  acts_as_authenticated_master_domain
  acts_as_authorized
  
  # TODO1 move to :before_layout
  # defer_static_scripts
  
  # TODO1
  # protect_from_forgery
  
  helper Users::GeneralHelper
  
  protected
  
    def catch_user_error
      begin
        yield
      rescue UserError => e
        raise e
        # {:error => e.message}
      end
    end
    around :catch_user_error
    
    def require_master_domain
      domain = workspace.request.host.sub(/\Awww\./, '')
      raise_user_error "Master Host required!" unless domain == config.master_domain!
    end
    before :require_master_domain
  
  
  
  
  
  
  
  
  
  
  
    
  
  
  
  
    # 
    # Theme support
    # 
    # before :set_theme
    # def set_theme
    #   @theme = "simplicity"
    # end
    
    # 
    # Logo and Breadcrumb
    #     
    # def self.logo opt = {}, &block
    #   before opt do |controller|
    #     controller.instance_variable_set "@logo", controller.instance_eval(&block)
    #   end
    # end
    
    
    # TODO2 move to :before_layout
    def self.breadcrumb opt = {}, &block
      before opt do |controller|
        controller.instance_variable_set "@breadcrumb", controller.instance_eval(&block)
      end
    end    
    
    def self.active_menu opt = {}, &block
      before opt do |controller|
        controller.instance_variable_set "@active_menu", controller.instance_eval(&block)
      end
    end
    
    
end