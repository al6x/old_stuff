class Multitenant::SessionsController < Multitenant::MultitenantController
  filter_parameter_logging :password
  
  before_filter :return_cas_token_if_authenticated, :only => :login

  # before_filter :login_required, :only => :destroy
  before_filter :login_not_required, :only => :login  
  
  layout 'multitenant'
  
  persist_params
  
  def login    
    if using_open_id?
      open_id_authentication
    elsif request.post?
      password_authentication
    end
  end

  def logout
    unless User.current.anonymous?
      set_current_user_with_updating_session User.anonymous
      flash[:info] = t :successfully_logged_out
    end    
    redirect_to return_to_path_with_logout_cas_token
  end
  
  protected
    def open_id_authentication
      # params['return_to'] = request.url
      # hack to save all url with :_return_to
      # puts params['return_to']
      # render :action => 'new'
      # return
      
      # return_to = request.url.gsub("_ret")
      
      authenticate_with_open_id nil, 'return_to' => request.url do |result, identity_url, registration|

        if result.successful?
          if @user = User.authenticate_by_open_id(identity_url)
            set_current_user_with_updating_session @user
            flash[:info] = t :successfully_logged_in
            redirect_to return_to_path_with_cas_token
          else
            token = SecureToken.new
            token[:open_id] = identity_url
            token.save!
            flash[:sticky_info] = t :successfully_identified_by_open_id
            redirect_to finish_open_id_registration_form_identities_path(:token => token.token)
          end
        else
          flash[:error] = result.message || t(:invalid_identity, :identity => identity_url)
        end
        
      end
    end
  
    def password_authentication
      if @user = User.authenticate_by_password(params[:name], params[:password])
        set_current_user_with_updating_session @user
        flash[:info] = t :successfully_logged_in
        redirect_to return_to_path_with_cas_token
      else      
        @errors = t :invalid_login
        @name = params[:name]
      end
    end
        
end
