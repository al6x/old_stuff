require 'rad/assets/gems'

require 'vfs'
require 'rad'

class Rad::Assets
  autoload :StaticFiles, 'rad/assets/static_files'
end

%w(
  compressor
  assets
  resource
  packaged_resource
  view_helper
).each{|f| require "rad/assets/#{f}"}


Rad::Template::Context.include Rad::Assets::ViewHelper