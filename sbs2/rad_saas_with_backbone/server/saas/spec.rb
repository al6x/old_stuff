require 'rad/spec'
require 'mongo/model/spec'

require 'saas/spec/_factories'

# Space.

rad.register(:account){factory.build :account}
rad.register(:space){rad.account.spaces.first}

rspec do
  class << self
    alias_method :with_models_without_saas, :with_models
    def with_models
      with_models_without_saas

      require 'saas/spec/_models'
    end
  end
end

# User.

rad.register :user

rspec do
  def login_as user, options = {}
    user = factory.build user, options if user.is_a? Symbol
    rad.user = user
  end

  def self.login_as name, options = {}
    before{login_as name, options}
  end
end