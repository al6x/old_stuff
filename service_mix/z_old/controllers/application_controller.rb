class ApplicationController < ActionController::Base
  before_filter :ensure_no_www
  
  acts_as_localized
  acts_as_authenticated
  acts_as_authorized
  
  defer_static_scripts
  
  helper :all
  protect_from_forgery
  
  protected
      
    # 
    # Logo and Breadcrumb
    #     
    # def self.logo opt = {}, &block
    #   before_filter opt do |controller|
    #     controller.instance_variable_set "@logo", controller.instance_eval(&block)
    #   end
    # end
    
    def self.breadcrumb opt = {}, &block
      before_filter opt do |controller|
        controller.instance_variable_set "@breadcrumb", controller.instance_eval(&block)
      end
    end    
    
    def self.active_menu opt = {}, &block
      before_filter opt do |controller|
        controller.instance_variable_set "@active_menu", controller.instance_eval(&block)
      end
    end
end