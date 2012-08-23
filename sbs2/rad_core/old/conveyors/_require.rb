class Rad::Conveyors
end

%w(
  _params
  _workspace
  _processor
  _conveyor
  _conveyors
).each{|f| require "rad/conveyors/#{f}"}