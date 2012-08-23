# Defining custom form tags
Rad::Face::ThemedFormHelper.generate_form_helper_methods %w(attachments_tag)
 
# Libraries 
%w(
  ci_view_helper
  ci_model_helper
).each{|f| require "face/#{f}"}

# Helpers
Rad::Controller::Context.inherit Rad::Face::CiViewHelper
Rad::Html::ModelHelper.inherit Rad::Face::CiModelHelper

# Demo
module Rad::Face::Demo
  autoload :Base,       'face/demo/base'
  autoload :Helps,      'face/demo/helps'
  autoload :ViewHelper, 'face/demo/view_helper'
  autoload :Commons,    'face/demo/commons'
  autoload :Dialogs,    'face/demo/dialogs'
  autoload :Sites,      'face/demo/sites'  
end