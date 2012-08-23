require 'rad'

require 'vos'
require 'vos/drivers/s3'


# Configuring Runtime
rad.web
rad.configure :runtime, rad.runtime_path do |rt|
  rt.routes
end


# Assembling Application
rad.themes
rad.bag
rad.store