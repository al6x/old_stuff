require 'rad'

rad.mode = :production unless rad.mode?

load "#{__FILE__.dirname}/init.rb"

rad.http.configure_rack! self
run rad.http