require 'rad/spec'
require 'rad_ext/spec'

rspec do
  class << self
    alias_method :with_models_without_user, :with_models

    def with_models
      with_models_without_user

      require 'spec_helper/user_stub'
      require 'spec_helper/user_factories'
    end
  end
end