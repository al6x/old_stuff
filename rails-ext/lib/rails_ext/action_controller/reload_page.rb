ActionController::Base.send :class_eval do
  protected
  def reload_page
    preserve_flash_for_ajax_page_update
    render :inline => "window.location.reload();", :layout => 'application'
  end
end