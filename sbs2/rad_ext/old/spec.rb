require 'rad_ext'

require 'rad/spec'

require 'rad_ext/spec/_models'
require 'rad_ext/spec/_factories'

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