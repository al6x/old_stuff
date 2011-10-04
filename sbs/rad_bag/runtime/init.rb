#
# Loading Users
#
users_lib_dir = File.expand_path "#{__FILE__}/../../lib"
$LOAD_PATH << users_lib_dir unless $LOAD_PATH.include? users_lib_dir


#
# Initializing Rad
#
require 'rad'
rad.web

#
# Configuring Runtime
#
rad.configure :runtime, __FILE__.dirname do |rt|
  rt.config
end


#
# Assembling Application
#
rad.bag