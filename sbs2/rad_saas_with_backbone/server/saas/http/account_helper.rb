module Saas::Http::AccountHelper
  inject :logger, :request, :params

  def get_account
    account = Models::Account.first domains: request.rack_request.normalized_domain

    unless account
      msg = "no Account registered for the '#{request.normalized_domain}' Domain!"
      logger.debug msg
      raise msg
    end

    unless account.enabled?
      msg = "account #{account.name} disabled!"
      logger.debug msg
      raise msg
    end

    account
  end
end