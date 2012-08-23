# Conveyor is the heart of Rad, it allows for Processors to process request and build responce.

rad.register :conveyors do
  require 'rad/conveyors/_require'

  Rad::Conveyors.new
end