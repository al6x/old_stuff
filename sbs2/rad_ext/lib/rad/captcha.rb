class Rad::Captcha
  attr_accessor :public_key, :private_key, :timeout, :enabled, :verify_url
  attr_required :private_key, :public_key
  def enabled?; !!enabled end

  inject :request

  # Usually used with `rad.user.anonymous? and !request.get?` checks.
  def verify
    return true unless enabled?

    challenge = request.params[:recaptcha_challenge_field]
    response = request.params[:recaptcha_response_field]
    return false unless challenge and response

    require 'net/http'

    recaptcha = nil
    Timeout::timeout(timeout || 3) do
      recaptcha = Net::HTTP.post_form URI.parse(verify_url), {
        'privatekey' => private_key,
        'remoteip' => request.ip,
        'challenge' => challenge,
        'response' => response
      }
    end
    result = recaptcha.body.split.map { |s| s.chomp }
    answer, error = result
    answer == 'true'
  end
end