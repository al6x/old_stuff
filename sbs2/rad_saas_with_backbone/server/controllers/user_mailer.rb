class Controllers::UserMailer
  inherit Rad::Controller
  inject router: :http_router
  inject :http, :locale

  def email_verification token
    url = build_url '/finish_registration', token: token.token
    Rad::Letter.new \
      to:      token.email,
      from:    rad.saas.email,
      subject: t(:email_verification_title, host: http.host),
      body:    t(:email_verification_text, host: http.host, url: url)
  end

  def forgot_password token
    url = build_url '/reset_password', token: token.token
    Rad::Letter.new \
      to:      token.user.email,
      from:    rad.saas.email,
      subject: t(:forgot_password_title, name: token.user.name, host: http.host),
      body:    t(:forgot_password_text, name: token.user.name, host: http.host, url: url)
  end

  protected
    def build_url url, params
      router.build_url url, params.merge(host: http.host, l: locale.current)
    end
end