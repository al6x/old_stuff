# Ruby.
raise 'ruby 1.9.2 or higher required!' unless RUBY_VERSION >= '1.9.2'
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Gem versions.
require 'rad/gems'

# Vendor Libraries.

require 'ruby_ext'

$dont_create_micon_shortcut = true
require 'micon'
def rad; ::MICON end

require 'class_loader'

require 'vfs'

require 'json'

require 'yaml_fix'

# Libraries.

[
  '_micon',
  '_module',
  '_string',
  '_exception',
  '_extensions',
  '_miscellaneous'
].each{|f| require "rad/support/#{f}"}

module Rad
  autoload :Filters, 'rad/support/_filters'
  autoload :Mime, 'rad/support/_mime'
end

autoload :Uri, 'rad/support/_addressable'