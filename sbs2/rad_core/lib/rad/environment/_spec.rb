require 'rspec_ext'
require 'micon/spec'

rad.mode = :test

require 'logger'
rad.logger = Logger.new nil
rad.runtime_path = 'tmp', true