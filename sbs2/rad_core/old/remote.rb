rad.register :remote, depends_on: :conveyors do
  require 'rad/remote/_require'
  Rad::Remote.new
end