require 'rad'
require 'saas_extensions'

require 'saas/factories'


#
# Ignoring the :space prefix
#
Rad::Router::AbstractRouter.class_eval do
  def encode_prefix_params! path, params, meta
    path
  end
end


#
# Space and Account
#
rad.register :account
rad.register :space

rad.register_extension :with_models do
  before do
    Models::Account
    rad.account = Factory.create :account
    rad.space = rad.account.spaces.first
  end
  after do
    rad.delete :account
    rad.delete :space
  end
end

Rad::Controller::Multitenant.class_eval do
  protected
    alias_method :set_account_and_space_without_spec, :set_account_and_space

    def set_account_and_space
      params.space ||= rad.space.name #'default'
      yield
    end
end