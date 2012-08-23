module Captcha
  def captcha_tag
    return "" if rad.test?

    captcha_html = recaptcha_tags public_key: config.recaptcha[:public_key],
                   display: {theme: :custom, custom_theme_widget: 'recaptcha_widget'}

    render "/kit/captcha", locals: {captcha_html: captcha_html}
  end
end