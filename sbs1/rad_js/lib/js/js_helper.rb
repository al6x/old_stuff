module Rad::JsHelper
  def initialize_js_commons
    javascript_tag %{\
window.AUTHENTICITY_TOKEN = "#{authenticity_token}";}
  end    
end