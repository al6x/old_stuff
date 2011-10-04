# 
# ordinary and ajax flash[:info] (othervise it appears twice with ajax requests)
# 
ActionController::Base.class_eval do
  def flash_with_ajax
    (request.xhr? or request.format == 'js') ? flash_without_ajax.now : flash_without_ajax
  end
  alias_method_chain :flash, :ajax
end