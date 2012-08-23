class Rad::Remote
end

%w(
  _remote_controller
).each{|f| require "rad/remote/#{f}"}