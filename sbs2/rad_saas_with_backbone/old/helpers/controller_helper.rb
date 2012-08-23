module ControllerHelper
  module ClassMethods
    #
    # Navigation
    #
    def logo opt = {}, &block
      before opt do |controller|
        controller.instance_variable_set "@logo", controller.instance_eval(&block)
      end
    end

    def breadcrumb opt = {}, &block
      before opt do |controller|
        controller.instance_variable_set "@breadcrumb", controller.instance_eval(&block)
      end
    end

    def active_menu opt = {}, &block
      before opt do |controller|
        controller.instance_variable_set "@active_menu", controller.instance_eval(&block)
      end
    end
  end

  protected
    def set_theme
      @theme = "simplicity"
    end
end