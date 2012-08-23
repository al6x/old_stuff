require 'rad'
runtime_path = __FILE__.dirname

rad.mode = :production unless rad.mode?
rad.runtime_path = runtime_path unless rad.runtime_path?

load "#{runtime_path}/init.rb"

rad.http.configure_rack! self
run rad.http