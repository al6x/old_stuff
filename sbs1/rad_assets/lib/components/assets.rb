rad.register :assets, depends_on: :environment do
  require 'rad/assets/require'
  Rad::Assets.new
end