ActionController::Base.send :class_eval do
  protected
  def default_path options = {}
    url_for_path SETTING.default_path!, options.merge(:no_prefix => true)
  end

  def return_to_path options = {}
    do_not_persist_params do 
      url_for_path params[:_return_to] || session[:return_to] || SETTING.default_path!, options.merge(:no_prefix => true)
    end
  end
    
  helper_method :default_path, :return_to_path
end