class Identities < Users::Abstract
  # TODO2
  # filter_parameter_logging :password, :password_confirmation, :old_password
  
  before :return_cas_token_if_authenticated, :only => :new
  
  before :login_required, :only => [
    :update_password_form, :update_password,
    :destroy
  ]

  before :login_not_required, :only => [
    :enter_email_form, :enter_email, 
    :finish_email_registration_form, :finish_email_registration,
    
    :finish_open_id_registration_form, :finish_open_id_registration,
    
    :reset_password_form, :reset_password,
    :forgot_password_form, :forgot_password
  ]
  
  # TODO1 fixme
  # persist_params :only => [:finish_open_id_registration_form, :finish_open_id_registration]
    
  layout '/users/layouts/general'
    
  # 
  # Email and Password
  #   
  def enter_email_form
    @token = Users::EmailVerificationToken.new
  end
  
  def enter_email
    @token = Users::EmailVerificationToken.new params[:token]
    @token.expires_at = 2.weeks.from_now
    if @token.save
      flash.now[:sticky_info] = t :email_verification_code_sent, :email => @token.email
      render :inline => "", :layout => 'multitenant'
    else
      render :action => 'enter_email_form'
    end
  end
  
  def finish_email_registration_form
    @token = Users::EmailVerificationToken.by_token params[:token]
    raise_user_error t(:invalid_email_verification_token) unless @token
    
    @user = User.new
  end
  
  def finish_email_registration
    @token = Users::EmailVerificationToken.by_token params[:token]

    @user = User.new
    @user.email = @token.email    
    %w{name password password_confirmation}.each do |attr|
      @user.send "#{attr}=", params[:user][attr.to_sym] if params[:user]
    end
    
    if @user.activate and @user.save
      @token.destroy
      flash[:sticky_info] = t :successfully_registered
      redirect_to login_path(:_return_to => nil)
    else
      render :finish_email_registration_form
    end
  end
    
  def forgot_password_form
  end
  
  def forgot_password
    @email = params[:email]
    user = User.first :conditions => {:state => 'active', :email => @email}
    if user
      Users::ForgotPasswordToken.create! :user => user
      flash[:sticky_info] = t :sucessfully_reset_password, :email => @email
      redirect_to default_path
    else
      flash.now[:sticky_error] = t :failed_reset_password, :email => @email
      render :forgot_password_form
    end
  end
  
  def reset_password_form
    @token = Users::ForgotPasswordToken.by_token params[:token]
    raise_user_error t(:invalid_reset_password_token) unless @token    
    @user = @token.user    
  end
  
  def reset_password
    @token = Users::ForgotPasswordToken.by_token params[:token]
    raise_user_error t(:invalid_reset_password_token) unless @token    
    @user = @token.user

    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    
    if @user.save
      @token.destroy
      flash[:sticky_info] = t :password_restored
      redirect_to login_path(:_return_to => nil)
    else
      render :reset_password_form
    end
  end
  
  def update_password_form
    @user = User.current
    render :update_password_form
  end
  
  def update_password
    @user = User.current

    if @user.update_password(params[:user][:password], params[:user][:password_confirmation], params[:old_password]) and @user.save             
      flash[:sticky_info] = t :password_updated
      redirect_to default_path
    else
      render :update_password_form
    end
  end
  
  
  # 
  # Open Id
  # 
  def finish_open_id_registration_form
    @user = User.new
    @token = SecureToken.by_token! params[:token]
  end
    
  def finish_open_id_registration
    @token = SecureToken.by_token! params[:token]
    @user = User.new
    @user.name = params[:user][:name]
    @user.open_ids << @token[:open_id]
    
    if @user.activate and @user.save
      @token.destroy
      flash[:sticky_info] = t :successfull_open_id_registration
      set_current_user_with_updating_session @user      
      redirect_to return_to_path_with_cas_token
    else
      render :action => :finish_open_id_registration_form
    end
  end
end
