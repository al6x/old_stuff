ActionController::Base.class_eval do
  class << self
    def enable_wigets *args
      ServiceMix.require_assets
      helper ServiceMix::WigetHelper
      before_filter do |c|
        c.send :set_wigets_initialization_parameters, *args
      end
    end
  end
  
  protected
    def set_wigets_initialization_parameters params = {}, secure_params = {}      
      @wigets_initialization_parameters = {:params => params, :secure_params => secure_params}
    end
end