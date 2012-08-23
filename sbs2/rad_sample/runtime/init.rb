root_path = File.expand_path "#{__FILE__}/../.."
$LOAD_PATH << "#{root_path}/lib" unless $LOAD_PATH.include? "#{root_path}/lib"

require 'blog/gems'
require 'rad'

rad.blog

rad.http.stack.unshift(-> builder {
  if rad.production?
    filters = /^\/.*?\/static\/|^\/static\/|\/favicon/
    builder.use Rad::Assets::StaticFiles, filters
  end
})