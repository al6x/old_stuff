# 
# Usually You don't need this config.ru file (the /runtime/config.ru is used),
# but because we need to support Heroku depolyment we also need this file.
# It's just a clone of /runtime/config.ru with a little different paths.
# 
require 'rad'
runtime_path = "#{__FILE__.dirname}/runtime"

rad.mode = :production unless rad.mode?
rad.runtime_path = runtime_path unless rad.runtime_path?

load "#{runtime_path}/init.rb"

rad.http.configure_rack! self
run rad.http