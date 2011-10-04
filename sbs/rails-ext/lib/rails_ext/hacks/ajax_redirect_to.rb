ActionController::Base.send :class_eval do
  protected
  def redirect_to_with_ajax *args
    if request.xhr? or request.format == 'js'
      preserve_flash_for_ajax_page_update
      render :inline => "window.location = '#{url_for *args}';", :layout => 'application'
    else
      redirect_to_without_ajax *args
    end
  end
  alias_method_chain :redirect_to, :ajax
  
  private
  def preserve_flash_for_ajax_page_update
    # save flash.now (that are marked as used) with ajax redirect
    used = flash_without_ajax.instance_variable_get '@used'
    used.clear
  end
end