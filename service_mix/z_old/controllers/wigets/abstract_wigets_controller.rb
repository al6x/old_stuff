class Wigets::AbstractWigetsController < ActionController::Base
  filter_parameter_logging SETTING.session_key! #, :secure_params
  
  acts_as_localized
  
  acts_as_wiget
  
  acts_as_authenticated
  acts_as_authorized
  
  acts_as_multitenant
end