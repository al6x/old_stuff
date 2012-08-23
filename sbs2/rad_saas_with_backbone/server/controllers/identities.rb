class Controllers::Identities < Controllers::Saas
  before :registered_user_required, only: :update_password

  def generate_email_confirmation_token
    token = Models::User::EmailVerificationToken.new params
    token.expires_at = Time.now + 2 * 7 * 24 * 3600

    Controllers::UserMailer.new.email_verification(token).deliver if token.save

    token.to_rson :public
  end

  def create_user
    token = Models::User::EmailVerificationToken.by_token params[:token]

    user = Models::User.new
    %w{name password password_confirmation}.each do |a|
      user.send "#{a}=", params[a.to_sym]
    end

    if token
      user.email = token.email
      token.delete if user.activate and user.save
    else
      user.errors.add :base, t(:invalid_email_verification_token)
    end

    user.to_rson :public
  end

  def generate_reset_password_token
    email = params[:email]
    user = Models::User.first state: 'active', email: email
    if user
      token = Models::User::ResetPasswordToken.create! user: user
      Controllers::UserMailer.new.forgot_password(token).deliver
      {}
    else
      {errors: {base: [t(:failed_reset_password, email: email)]}}.to_rson
    end
  end

  def reset_password
    password, confirmation = params[:password], params[:password_confirmation]

    if token = Models::User::ResetPasswordToken.by_token(params[:token])
      user = token.user

      user.password = password
      user.password_confirmation = confirmation

      if user.save
        token.delete
        {}
      else
        user.to_rson :public
      end
    else
      {errors: {base: [t(:invalid_reset_password_token)]}}.to_rson
    end
  end

  def update_password
    args = [params[:old_password], params[:password], params[:password_confirmation]]
    if user.update_password(*args) and user.save
      {}
    else
      user.to_rson :public
    end
  end
end