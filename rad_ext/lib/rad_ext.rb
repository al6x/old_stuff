require 'rad'
require 'rad_ext/gems'

lib_dir = __FILE__.dirname
autoload_dir lib_dir

rad.must_not.include :web
rad.register :web, depends_on: [:html, :router, :controller, :http] do  
  require 'rad/core_web/_require'
  require 'rad_ext/require'
  
  load 'rad_ext/profiles/web_ext.rb'
  load 'rad/profiles/mailer.rb'
  
  rad.assets
  
  true
end