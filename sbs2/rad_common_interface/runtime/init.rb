#
# Load path
#
lib_dir = File.expand_path "#{__FILE__}/../../lib"
$LOAD_PATH << lib_dir unless $LOAD_PATH.include? lib_dir


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


rad.common_interface